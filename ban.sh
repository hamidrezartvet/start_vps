#!/bin/bash

# Update and install nftables
echo "Updating system and installing nftables..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y nftables curl

# Enable and start nftables service
echo "Enabling nftables service..."
sudo systemctl enable nftables
sudo systemctl start nftables

# Define variables for the IP list and nftables config
IP_LIST_URL="https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/i.txt"
LOCAL_IP_LIST="/tmp/blocked_ips.txt"
NFTABLES_CONFIG="/etc/nftables.conf"

# Step 1: Download the IP list
echo "Downloading the IP list..."
curl -s "$IP_LIST_URL" -o "$LOCAL_IP_LIST"

# Check if the file was downloaded successfully
if [ ! -s "$LOCAL_IP_LIST" ]; then
    echo "Failed to download IP list or the list is empty. Exiting."
    exit 1
fi
echo "Downloaded IP list with $(wc -l < "$LOCAL_IP_LIST") entries."

# Step 2: Generate nftables ruleset
echo "Creating nftables ruleset..."
sudo bash -c "cat > $NFTABLES_CONFIG" << 'EOF'
table ip filter {
    set blocked_ips {
        type ipv4_addr
        elements = {}
    }

    chain output {
        type filter hook output priority 0; policy accept;
        ip daddr @blocked_ips tcp dport { 80, 443 } drop
    }
}
EOF

# Step 3: Populate the IP set in nftables
echo "Populating blocked IPs into nftables..."
# Convert IP list into nftables format
IP_ELEMENTS=$(awk '{printf "\"%s\", ", $1}' "$LOCAL_IP_LIST" | sed 's/, $//')
sudo nft add element ip filter blocked_ips { $IP_ELEMENTS }

# Step 4: Save the nftables ruleset
echo "Saving nftables ruleset..."
sudo nft list ruleset > "$NFTABLES_CONFIG"

# Step 5: Verify and display the ruleset
echo "Displaying the current nftables rules:"
sudo nft list ruleset

echo "Blocking outgoing traffic to specified IPs is complete!"