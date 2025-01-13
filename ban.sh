#!/bin/bash
# Update and install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y curl unzip perl xtables-addons-common \
libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl \
iptables-persistent nftables

# URL of the IP list
url="https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/i.txt"

# Fetch the IP list and count total entries
allcount=$(curl -s "$url" | wc -l)

# Block traffic based on the IP list
curl -s "$url" | while IFS= read -r line; do
    ((++line_number))
    # Block outgoing traffic
    iptables -A OUTPUT -d "$line" -j DROP
    # Block incoming traffic
    iptables -A INPUT -s "$line" -j DROP
    # Block forwarded traffic
    iptables -A FORWARD -s "$line" -j DROP
    iptables -A FORWARD -d "$line" -j DROP
    clear
    echo "Blocking Iran IPs (List 1): $line_number / $allcount"
done

# Save the rules persistently
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# Additional security enhancements
echo "Enhancing security with additional rules..."

# Block all UDP traffic to specific ports (e.g., 53 for DNS tunneling)
iptables -A OUTPUT -p udp --dport 53 -j DROP
iptables -A INPUT -p udp --sport 53 -j DROP

# Rate-limiting to prevent abuse
iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j DROP

# Reload nftables (optional for advanced DPI)
sudo systemctl restart nftables.service

echo "All rules applied. Iran IPs blocked!"