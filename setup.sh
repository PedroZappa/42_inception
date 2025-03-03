#!/usr/bin/env bash

# setup.sh - Creates environment files for Docker setup
# Usage: ./setup.sh [username]

# Default username if not provided
USERNAME=${1:-"passunca"}

# Create directories if they don't exist
mkdir -p ~/secrets/vault

# Function to create the secrets file
create_secrets_file() {
    local secrets_file="$1"
    
    cat > "$secrets_file" << EOF
db_password=dbpassword
db_root_password=dbrootpassword
wp_admin_password=wpapassword
wp_admin_email=${USERNAME}@student.42porto.com
wp_user_password=wpupassword
wp_user_email=pedrogzappa@gmail.com
ftp_password=ftppassword
EOF

    echo "Created secrets file: $secrets_file"
}

# Function to create the .env file
create_env_file() {
    local env_file="$1"
    local username="$2"
    
    cat > "$env_file" << EOF
USER=${username}
DOMAIN_NAME=\${USER}.42.fr
WWWLOCAL=/var/www/html/
# SSL Certificates
CERTS_=/etc/nginx/ssl/\${USER}.crt
# MySQL
MYSQL_DATABASE=mariadb_db
MYSQL_USER=user
MYSQL_HOST=mariadb
# WordPress
WP_ADMIN=wpa
WP_USER=wpu
# FTP
FTP_USER=ftpuser
# IRC
EOF

    echo "Created .env file: $env_file"
}

# Create the secrets file
SECRETS_FILE=~/secrets/secrets.txt
create_secrets_file "$SECRETS_FILE"

# Create the .env file
ENV_FILE=~/secrets/.env
create_env_file "$ENV_FILE" "$USERNAME"

# Create a dummy decryption key for the setup
echo "456zedro123" > ~/secrets/vault/decryptionKey.txt

# Optional: Encrypt the secrets file (uncomment if needed)
# cp "$SECRETS_FILE" ~/secrets/secrets.enc
# echo "Note: For production, you should properly encrypt the secrets file"

echo "Setup complete!"
echo "Files created:"
echo "  - $SECRETS_FILE"
echo "  - $ENV_FILE"
echo "  - ~/secrets/vault/decryptionKey.txt"
echo ""
echo "Next steps:"
echo "1. Review and modify the generated files at ~/secrets/ as needed"
echo "2. For production use, encrypt the secrets file"
echo "3. Run your Docker Compose setup"
