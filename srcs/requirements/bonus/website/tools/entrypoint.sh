#!/usr/bin/env bash

mkdir -p $HOME/data/ws

# Make sure HTML has current level of permissions
chown -R www-data:www-data /var/www/html

# Start Nginx
exec "$@"
