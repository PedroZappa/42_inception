#!/usr/bin/env bash

# Ensure directories exists and has correct permissions
mkdir -p /var/www/html
chmod -R 755 /var/www/html
chown -R www-data:www-data /var/www/html

# Download Adminer 
if [ ! -f /var/www/html/index.php ]; then
    wget -q -O /var/www/html/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php
fi

# Handle SIGTERM properly
cleanup() {
    echo "Terminating Adminer..."
    kill -TERM "$PHP_PID"
    wait "$PHP_PID"
    exit 0
}
trap cleanup TERM INT

# Start PHP's built-in web server in the background
php -S 0.0.0.0:8080 -t /var/www/html &
PHP_PID=$!

# Wait for PHP process
wait "$PHP_PID"
