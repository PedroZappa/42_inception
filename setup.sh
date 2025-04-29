#!/usr/bin/env bash
# setup.sh - Creates environment files and TLS certificates for Docker setup
# Usage: ./setup.sh [username]

set -euo pipefail  # Exit on errors, treat unset variables as errors, and prevent errors in pipelines

# Default username if not provided
USERNAME=${1:-"passunca"}

# Define paths
SECRETS_DIR="$HOME/secrets"
ENV_FILE="$SECRETS_DIR/.env"
TLS_DIR="$SECRETS_DIR/tls"
VAULT_DIR="$SECRETS_DIR/vault"
SECRETS_FILE="$VAULT_DIR/secrets.txt"
ENCRYPTED_FILE="$VAULT_DIR/secrets.enc"
KEY_FILE="$VAULT_DIR/decryptionKey.txt"

# Create necessary directories
# Ensure the secrets directory exists and has correct permissions
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
# Create necessary directories
mkdir -p "$TLS_DIR"
mkdir -p ~/data/ws ~/data/wp ~/data/db ~/data/unrealircd ~/data/doom
echo "Directories created successfully!"

if ln -sfn "$SECRETS_DIR" "${PWD}/secrets"; then
  echo "Created symlink: ./secrets -> $SECRETS_DIR"
fi

# Generate a dummy decryption key if it does not exist
if [[ ! -f "$KEY_FILE" ]]; then
    mkdir -p "$(dirname "$KEY_FILE")"
    echo "456zedro123" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo "Generated encryption key: $KEY_FILE"
fi

# Function to create the secrets file
create_secrets_file() {
    cat > "$SECRETS_FILE" << EOF
db_password=dbpassword
db_root_password=dbrootpassword
wp_admin_password=wpapassword
wp_admin_email=${USERNAME}@student.42porto.com
wp_user_password=wpupassword
wp_user_email=pedrogzappa@gmail.com
ftp_password=ftppassword
EOF
    chmod 600 "$SECRETS_FILE"
    echo "Created secrets file: $SECRETS_FILE"
}

# Function to create the .env file
create_env_file() {
    cat > "$ENV_FILE" << EOF
USER=${USERNAME}
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
EOF
    chmod 600 "$ENV_FILE"
    echo "Created .env file: $ENV_FILE"
}

# Function to encrypt the secrets file
encrypt_secrets() {
    # Encrypt the file
    openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
      -in "$SECRETS_FILE" \
      -out "$ENCRYPTED_FILE" \
      -pass file:"$KEY_FILE"
    chmod 600 "$ENCRYPTED_FILE"
    echo "Encrypted secrets file: $ENCRYPTED_FILE"
}

# Function to generate TLS certificates (only if missing)
generate_certificates() {
    if [[ ! -f "$TLS_DIR/server.cert.pem" || ! -f "$TLS_DIR/server.key.pem" ]]; then
        openssl req -x509 -newkey rsa:4096 -keyout "$TLS_DIR/server.key.pem" \
            -out "$TLS_DIR/server.cert.pem" -days 365 -nodes \
            -subj "/C=PT/ST=Porto/L=Porto/O=ZedroCorp/OU=IT/CN=172.18.0.7"  # Change CN to match your server
            # -subj "/CN=localhost"
        chmod 600 "$TLS_DIR/server.key.pem" "$TLS_DIR/server.cert.pem"
        echo "Generated new TLS certificates."
    else
        echo "TLS certificates already exist. Skipping generation."
    fi
}

# Execute functions
create_secrets_file
create_env_file
encrypt_secrets
generate_certificates

echo "Setup complete!"
echo "Files created:"
echo "  - $SECRETS_FILE (unencrypted - you should delete this after verification)"
echo "  - $ENCRYPTED_FILE (encrypted secrets)"
echo "  - $ENV_FILE"
echo "  - $KEY_FILE (keep this secure!)"
echo "  - TLS certificates in $TLS_DIR"
echo ""
echo "Next steps:"
echo "1. Review and modify the generated files in $SECRETS_DIR as needed"
echo "2. If you modify secrets.txt, run './setup.sh $USERNAME' again to re-encrypt"
echo "3. Once verified, remove the unencrypted secrets file: sudo rm $SECRETS_FILE"
echo "4. Run your Docker Compose setup"
