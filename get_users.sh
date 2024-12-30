#!/bin/bash

# Get terminal users
terminal_users=$(who | awk '{print $1}')

# Get PIDs of SSH VPN users connected on port 666
ssh_pids=$(ss -tnp | grep ':2024' | awk '{print $6}' | cut -d'=' -f2 | cut -d',' -f1)

# Convert PIDs to usernames and preserve duplicates
ssh_users=$(for pid in $ssh_pids; do ps -o user= -p "$pid"; done)

# Combine terminal and SSH VPN users (preserve duplicates)
all_users=$(echo -e "$terminal_users\n$ssh_users")

# Convert the list to a JSON array for PHP
json_array=$(echo "$all_users" | jq -R . | jq -s .)

# Save the JSON array to a file for PHP access
echo "$json_array" > /var/www/html/online_users.json
