#!/bin/bash

# Handle termination signals
cleanup() {
    echo "Gracefully stopping vsftpd..."
    kill -TERM "$VSFTPD_PID"
    wait "$VSFTPD_PID"
    exit 0
}
# Catch SIGTERM
trap cleanup SIGTERM

# Open script scope for secrets safety
# Decrypt secrets
if [ -f /run/secrets/secrets.enc ]; then
    echo "Decrypting Secrets to 'temporary file'... "
    openssl enc -aes-256-cbc -d -pbkdf2 -in /run/secrets/secrets.enc -out /run/secrets/secrets.txt -pass pass:$(cat /run/secrets/secret_key)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to decrypt secrets."
        exit 1
    fi
    echo "Secrets decrypted successfully."
else
    echo "Error: Encrypted secrets file not found."
    exit 1
fi

# Protect temporary secrets file
chmod 600 /run/secrets/secrets.txt

# Extract secrets into local scoped variable
FTP_PASSWORD=$(grep 'ftp_password=' /run/secrets/secrets.txt | cut -d '=' -f2)

# Cleanup temporary secrets file
rm /run/secrets/secrets.txt
echo "Temporary Secrets file deleted..."

# Create the FTP user if it doesn't exist
if ! id -u ${FTP_USER} &>/dev/null; then
    echo "Creating FTP user ${FTP_USER}..."
    useradd -m ${FTP_USER}
    echo -e "${FTP_PASSWORD}\n${FTP_PASSWORD}" | passwd ${FTP_USER}
fi

echo "Ensure FTP user has access to WordPress directory"
ln -s /var/ftp/users/${FTP_USER}/wordpress
chown -R ${FTP_USER}:${FTP_USER} /var/ftp/users/${FTP_USER}/wordpress
chmod -R 775 /var/ftp/users/${FTP_USER}/wordpress


# Start vsftpd in the foreground
echo "Starting vsftpd..."
vsftpd /etc/vsftpd.conf &
VSFTPD_PID=$!

wait "$VSFTPD_PID"
