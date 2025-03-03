#!/usr/bin/env bash

# Make sure HTML has current level of permissions
chown -R www-data:www-data /var/www/html

# Start Nginx
exec "$@"
