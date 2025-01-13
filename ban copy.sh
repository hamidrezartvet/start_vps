#!/bin/bash

# Update system and install nftables
echo "Updating system and installing nftables..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y nftables curl

# Enable and start nftables service
echo "Enabling nftables service..."
sudo systemctl enable nftables
sudo systemctl start nftables

# Define the URL for the IP list and temporary files
IP_LIST_URL="https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/i.txt"
BLOCKED_IP_FILE="/tmp/blocked_ips.txt"
NFTABLES_CONFIG="/etc/nftables.conf"

# Fetch the IP list
echo "Fetching IP list from $IP_LIST_URL..."
curl -s "$IP_LIST_URL" -o "$BLOCKED_IP_FILE"

# Check if the IP list is not empty
if [ ! -s "$BLOCKED_IP_FILE" ]; then
    echo "IP list is empty or could not be downloaded. Exiting."
    exit 1
fi

# Create nftables configuration
echo "Setting up nftables rules..."
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

# Populate the blocked IP set
echo "Populating blocked IP set in nftables..."
sudo nft flush set ip filter blocked_ips
while IFS= read -r ip; do
    sudo nft add element ip filter blocked_ips { "$ip" }
done < "$BLOCKED_IP_FILE"

# Save the nftables rules persistently
echo "Saving nftables rules..."
sudo nft list ruleset > "$NFTABLES_CONFIG"

# Display current rules
echo "Current nftables rules:"
sudo nft list ruleset

echo "Outgoing traffic to blocked IPs is now restricted!"