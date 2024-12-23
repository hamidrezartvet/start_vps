#!/bin/bash

# Get the connected username
USERNAME=$(whoami)

# Call the remote PHP script with curl, passing the username
MESSAGE=$(curl -s "http://dashbord.notefinderstack.cfd/api/createwelcomemessage/Euxqk6F9j2c9KGrjD8mtf8oU9IA7cmZM/${USERNAME}")

# Display the message to the user
echo "------------------------------------"
echo $USERNAME
echo "------------------------------------"

# Continue to the default shell
exec "$SHELL" -l
