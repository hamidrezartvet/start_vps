#!/bin/bash

# Define the URL and token as variables
BASE_URL="http://dashbord.notefinderstack.cfd/api/getusers/Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM"

# Construct the full URL
FULL_URL="${BASE_URL}"

# File to save the response
RESPONSE_FILE="/tmp/server_response.json"

# Fetch the users list using curl and save it to a file
curl -s "$FULL_URL" -o "$RESPONSE_FILE"

# Display a message indicating where the response is saved
echo "Server response saved to $RESPONSE_FILE"

# Display the raw response
echo "Raw Server Response:"
cat "$RESPONSE_FILE"

# Validate if the response is valid JSON
if ! cat "$RESPONSE_FILE" | jq . > /dev/null 2>&1; then
    echo "Error: Invalid JSON response received."
    exit 1
fi

# Parse the JSON and extract users
users=$(cat "$RESPONSE_FILE" | jq -c '.[]')

# Check if the response contains users
if [[ -z "$users" ]]; then
    echo "No users found in the response."
    exit 0
fi

# Ensure the group `hrtvpn_users` exists
GROUP_NAME="hrtvpn_users"
if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
    echo "Creating group: $GROUP_NAME"
    sudo groupadd "$GROUP_NAME"
else
    echo "Group $GROUP_NAME already exists."
fi

# Add each user from the JSON response
echo "Adding users..."
for user in $users; do
    # Extract username and password from JSON
    username=$(echo "$user" | jq -r '.username')
    password=$(echo "$user" | jq -r '.password')

    # Skip if username or password is empty
    if [[ -z "$username" || -z "$password" ]]; then
        echo "Skipping invalid user entry: $user"
        continue
    fi

    # Add the user to the system
    echo "Adding user: $username"
    if id "$username" > /dev/null 2>&1; then
        echo "User $username already exists. Skipping..."
        continue
    fi

    sudo useradd "$username" -m -G "$GROUP_NAME" -d "/home/hrtvpn_users/$username" -s /bin/true

    # Set the user's password
    echo "$username:$password" | sudo chpasswd

    echo "User $username added successfully."
done

echo "All users processed."
