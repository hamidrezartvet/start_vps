#!/bin/bash

# Load configuration file for server URL and token
CONFIG_FILE="/etc/hrtvpn.conf"

# Check if configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Source configuration file
source "$CONFIG_FILE"

# Ensure the MAIN_SERVER_URL and TOKEN are set
if [[ -z "$MAIN_SERVER_URL" || -z "$TOKEN" ]]; then
    echo "MAIN_SERVER_URL or TOKEN is not set in $CONFIG_FILE"
    exit 1
fi

# Construct the full URL with the token
FULL_URL="${MAIN_SERVER_URL}/${TOKEN}"

# Fetch the users list as encoded JSON using curl
encoded_response=$(curl -s "$FULL_URL")

# Check if the response is empty
if [[ -z "$encoded_response" ]]; then
    echo "Empty response from the server. Exiting."
    exit 1
fi

# Decode the JSON (assuming it is base64 encoded)
decoded_response=$(echo "$encoded_response" | base64 --decode)

# Parse the decoded response and check if it contains valid data
if [[ $(echo "$decoded_response" | jq '. | length') -eq 0 ]]; then
    echo "No users found in the decoded response. Exiting."
    exit 1
fi

# Check if the group 'hrtvpn_users' exists, create it if it doesn't
GROUP_NAME="hrtvpn_users"
if ! getent group "$GROUP_NAME" > /dev/null; then
    echo "Group $GROUP_NAME does not exist. Creating..."
    sudo groupadd "$GROUP_NAME"
else
    echo "Group $GROUP_NAME already exists."
fi

# Loop through the users and add them to the server
echo "$decoded_response" | jq -c '.[]' | while read -r user; do
    username=$(echo "$user" | jq -r '.username')
    password=$(echo "$user" | jq -r '.password')

    if id "$username" &>/dev/null; then
        echo "User $username already exists. Skipping."
    else
        echo "Adding user $username..."
        sudo useradd "$username" -m -G "$GROUP_NAME" -d /home/hrtvpn_users/ -s /bin/true
        echo "$username:$password" | sudo chpasswd
        echo "User $username added successfully."
    fi
done

echo "All users processed."
