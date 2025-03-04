#!/usr/bin/env bash

# Ensure the target directory exists
mkdir -p /var/www/html
mkdir -p ~/data/ws

# If a bind-mounted website exists, overwrite default files
if [ -d "../site/" ]; then
    # cp -r /mnt/ws_data/* /var/www/html/
    cp -r ../site/ /var/www/html/
    chown -R www-data:www-data $HOME/data/ws
    echo "✅ Custom website files injected:"
else
    echo "⚠️ Using default website from build"
fi

# Start Nginx
exec "$@"
