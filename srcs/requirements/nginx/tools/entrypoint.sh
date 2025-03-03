#!/usr/bin/env bash

USER=${1:-"passunca"}

# Create folder for certificates
mkdir -p /etc/nginx/ssl
export DOMAIN_NAME_PT=${USER}.42.pt
# create certificates
# # French
openssl req -x509 -nodes -days 365 -new -keyout /etc/nginx/ssl/${USER}-fr.key \
    -out /etc/nginx/ssl/${USER}-fr.crt -subj "/CN=$DOMAIN_NAME/O=42/OU=42Porto/C=PT/ST=Porto/L=Porto"
# # Portuguese
openssl req -x509 -nodes -days 365 -new -keyout /etc/nginx/ssl/${USER}-pt.key \
    -out /etc/nginx/ssl/${USER}-pt.crt -subj "/CN=$DOMAIN_NAME_PT/O=42/OU=42Porto/C=PT/ST=Porto/L=Porto"

# Start nginx server
exec nginx -g "daemon off;"
