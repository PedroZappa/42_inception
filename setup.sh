#!/usr/bin/env bash
# setup.sh - Creates environment files for Docker setup
# Usage: ./setup.sh [username]

# Default username if not provided
USERNAME=${1:-"passunca"}

# Create directories if they don't exist
mkdir -p ./secrets/vault
# Create a dummy decryption key for the setup
echo "456zedro123" > ./secrets/vault/decryptionKey.txt
chmod 600 ./secrets/vault/decryptionKey.txt

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


# Function to encrypt the secrets file
encrypt_secrets() {
    local input_file="$1"
    local output_file="$2"
    local key_file="$3"
    
    # Generate a random encryption key if not exists
    if [ ! -f "$key_file" ]; then
        openssl rand -base64 32 > "$key_file"
        chmod 600 "$key_file"
        echo "Generated new encryption key: $key_file"
    fi
    
    # Encrypt the file
    openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt -in "$input_file" -out "$output_file" \
        -pass file:"$key_file"
    
    echo "Encrypted secrets file created: $output_file"
}
#
# Capture the current working directory
CWD=$(pwd)
# Secrets Path
SECRETS_PATH=$HOME
# Create the secrets file
SECRETS_FILE=./secrets/secrets.txt
create_secrets_file "$SECRETS_FILE"

# Create the .env file
ENV_FILE=./secrets/.env
create_env_file "$ENV_FILE" "$USERNAME"

# Create the encrypted version
ENCRYPTED_FILE=./secrets/secrets.enc
KEY_FILE=./secrets/vault/decryptionKey.txt
encrypt_secrets "$SECRETS_FILE" "$ENCRYPTED_FILE" "$KEY_FILE"

# Only create symlink if it doesn’t exist
[ -L "$SECRETS_PATH" ] || ln -s "$CWD/secrets" "$SECRETS_PATH"


echo "Setup complete!"
echo "Files created:"
echo "  - $SECRETS_FILE (unencrypted - you should delete this after verification)"
echo "  - $ENCRYPTED_FILE (encrypted secrets)"
echo "  - $ENV_FILE"
echo "  - $KEY_FILE (keep this secure!)"
echo ""
echo "Next steps:"
echo "1. Review and modify the generated files at ~/secrets/ as needed"
echo "2. If you modify secrets.txt, run './setup.sh $USERNAME' again to re-encrypt"
echo "3. Once verified, remove the unencrypted secrets file: rm $SECRETS_FILE"
echo "4. Run your Docker Compose setup"
