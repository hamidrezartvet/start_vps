#!/bin/bash

# Update and install required packages
echo "Updating system and installing required tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y ipset iptables curl

# Define variables
IP_LIST_URL="https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/i.txt"
LOCAL_IP_LIST="/tmp/blocked_ips.txt"
IPSET_NAME="blocked_ips"

# Step 1: Download the IP list
echo "Downloading the IP list from $IP_LIST_URL..."
curl -s "$IP_LIST_URL" -o "$LOCAL_IP_LIST"

# Check if the IP list is valid
if [ ! -s "$LOCAL_IP_LIST" ]; then
    echo "Failed to download IP list or the list is empty. Exiting."
    exit 1
fi
echo "Downloaded IP list with $(wc -l < "$LOCAL_IP_LIST") entries."

# Step 2: Create or flush the ipset
echo "Setting up ipset..."
if sudo ipset list $IPSET_NAME > /dev/null 2>&1; then
    sudo ipset flush $IPSET_NAME
else
    sudo ipset create $IPSET_NAME hash:ip hashsize=1024 maxelem=65536
fi

# Step 3: Populate the ipset
echo "Adding IPs to ipset..."
while IFS= read -r ip; do
    sudo ipset add $IPSET_NAME "$ip"
done < "$LOCAL_IP_LIST"

# Step 4: Apply iptables rules for blocking outgoing traffic
echo "Applying iptables rules..."
sudo iptables -C OUTPUT -m set --match-set $IPSET_NAME dst -p tcp --dport 80 -j DROP 2>/dev/null || \
sudo iptables -A OUTPUT -m set --match-set $IPSET_NAME dst -p tcp --dport 80 -j DROP

sudo iptables -C OUTPUT -m set --match-set $IPSET_NAME dst -p tcp --dport 443 -j DROP 2>/dev/null || \
sudo iptables -A OUTPUT -m set --match-set $IPSET_NAME dst -p tcp --dport 443 -j DROP

# Step 5: Save ipset and iptables rules persistently
echo "Saving ipset and iptables rules..."
sudo ipset save > /etc/ipset.rules
sudo iptables-save > /etc/iptables/rules.v4

# Step 6: Configure ipset to load on boot
echo "Configuring ipset to load on boot..."
sudo bash -c "cat > /etc/systemd/system/ipset-persistent.service" << 'EOF'
[Unit]
Description=Restore ipset rules
After=network.target

[Service]
ExecStart=/sbin/ipset restore -f /etc/ipset.rules
ExecReload=/sbin/ipset restore -f /etc/ipset.rules
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable ipset-persistent.service
sudo systemctl start ipset-persistent.service

echo "Blocking outgoing traffic to IPs in the list is complete!"