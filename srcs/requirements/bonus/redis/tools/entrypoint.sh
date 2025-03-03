#!/usr/bin/env bash

# Search & replace IP
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf
# Append to redis.conf
echo <<EOF > /etc/redis/redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lfu
vm.overcommit_memory = 1
EOF

