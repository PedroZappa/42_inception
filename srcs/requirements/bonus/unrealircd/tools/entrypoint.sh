#!/usr/bin/env bash

# Navigate to the UnrealIRCd directory
cd /home/unrealircd_user/unrealircd

# Start UnrealIRCd in the foreground
# The -f flag runs UnrealIRCd in the foreground, which is crucial for container runtime
#
# # Start UnrealIRCd
# cd /unrealircd-${UNREALIRCD_VERSION}
./unrealircd configtest
./unrealircd start
./unrealircd status
./unrealircd restart

# Get the container's IP address on the Docker network
CONTAINER_IP=$(hostname -i)

# Display the command to connect from another terminal
echo "To connect to the UnrealIRCd server, use the following command in another terminal window:"
echo "Weechat example : /server add passunca.42.org localhost/6667 -notls"
echo "Or              : /server add passunca.42.org $CONTAINER_IP/6667 -notls"
echo "Then            : /connect passunca.42.org"
