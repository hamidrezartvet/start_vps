#!/bin/bash
sudo apt-get install jq -y

source /etc/hrtvpn.conf

# Fetch the users list using curl
response=$(curl -s "$MAIN_SERVER_URL")

# Parse the response and check if it contains valid data
if [[ $(echo "$response" | jq '. | length') -eq 0 ]]; then
    echo "No users found in the response. Exiting."
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
echo "$response" | jq -c '.[]' | while read -r user; do
    username=$(echo "$user" | jq -r '.username')
    password=$(echo "$user" | jq -r '.password')

    if id "$username" &>/dev/null; then
        echo "User $username already exists. Skipping."
    else
        echo "Adding user $username..."
        sudo useradd "$username" -m -G "$GROUP_NAME" -d /home/hrtvpn_users/magicpc -s /bin/true
        echo "$username:$password" | sudo chpasswd
        echo "User $username added successfully."
    fi
done

echo "All users processed."