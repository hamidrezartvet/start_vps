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

# Display the parsed JSON
echo "Parsed JSON:"
cat "$RESPONSE_FILE" | jq .

# Additional processing could go here if needed
echo "Script execution completed successfully."
