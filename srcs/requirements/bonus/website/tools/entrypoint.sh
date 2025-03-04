#!/usr/bin/env bash

sudo chown -R $(whoami):$(whoami) ~/data/ws
chmod -R 755 ~/data/ws
mkdir -p $HOME/data/ws

# Make sure HTML has current level of permissions
chown -R www-data:www-data /var/www/html

# Start Nginx
exec "$@"
