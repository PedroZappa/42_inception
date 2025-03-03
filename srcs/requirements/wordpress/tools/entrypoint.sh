#!/usr/bin/env bash

# Entrypoint script for WordPress docker image

ENCRYPTED_FILE=/run/secrets/secrets.enc
DENCRYPTED_FILE=/run/secrets/secrets.txt

# Create folders for PHP & Wordpress
mkdir -p /run/php/
mkdir -p /var/www/html/wordpress

cd /var/www/html/wordpress

# Decrypt secrets.enc
if [ -f /run/secrets/secrets.enc ]; then
    echo "Decrypting secrets file into /run/secrets/secrets.txt..."
    openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
        -in $ENCRYPTED_FILE -out $DENCRYPTED_FILE \
        -pass pass:$(cat /run/secrets/secret_key)
    echo "Decrypted secrets file into /run/secrets/secrets.txt"
else
    echo "Error: Secrets file not found"
    exit 1
fi

