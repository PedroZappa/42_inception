#!/usr/bin/env bash

# Create doom data directory
mkdir -p /data/doom
cd /data/doom

# Print debug information
echo "Current directory: $(pwd)"
ls -al


# Trap SIGTERM and forward it to the child process
trap 'kill -TERM $child' SIGTERM SIGINT

# Start terminal-doom
echo "Starting terminal-doom..."
/terminal-doom/zig-out/bin/terminal-doom &


# Store the PID of the application
child=$!

# Wait for the application to terminate
wait $child

# Exit with the same code as the application
exit $?
