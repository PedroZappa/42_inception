#!/usr/bin/env bash

# Create doom data directory
mkdir -p /data/doom
cd /data/doom

# Print debug information
echo "Current directory: $(pwd)"
ls -al

# Start a netcat listener to keep the container running
# This allows potential network interaction and prevents the container from exiting
nc -lk -p 3333 & 

# Start terminal-doom
echo "Starting terminal-doom..."
/terminal-doom/zig-out/bin/terminal-doom
