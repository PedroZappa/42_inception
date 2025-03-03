#!/usr/bin/env bash

SOCKET_PATH="/var/run/mysqld"
SOCKET_FILE="${SOCKET_PATH}/mysqld.sock"
DATA_PATH="/var/lib/mysql"

# Make sure socket Path is valid
if [ ! -d "$SOCKET_PATH" ]; then
    mkdir -p "$SOCKET_PATH"
    chown -R mysql:mysql "$SOCKET_PATH"
fi

# Make sure data directory exists
if [ ! -d "$DATA_PATH" ]; then
    mkdir -p "$DATA_PATH"
    chown -R mysql:mysql "$DATA_PATH"
fi

# Make sure MariaDB is initialized
if [ ! -d "${DATA_PATH}/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysqld --initialize-insecure --datadir=${DATA_PATH} --user=mysql
    echo "MariaDB database successfully initialized."
else
    echo "MariaDB database already exists, checking permissions..."
    chown -R mysql:mysql "${DATA_PATH}"
fi

# Start MariaDB in the background
mysqld_safe --datadir=${DATA_PATH} --socket=${SOCKET_FILE} --user=mysql &
echo "Preparing MariaDB's setup..."
while ! mysqladmin --socket="${SOCKET_FILE}" ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

SECRETS_FILE="/run/secrets/secrets.txt"
SECRETS_ENC="/run/secrets/secrets.enc"

# Create a security scope for handling secrets safely
(
    # Decrypt secrets file using the secret key
    if [ -f "$SECRETS_ENC" ]; then
        openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 -in "$SECRETS_ENC" -out "$SECRETS_FILE" \
            -pass pass:"$(cat /run/secrets/secret_key)"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to decrypt secrets file"
            exit 1
        fi
    else
        echo "Error: Secrets file not found"
        exit 1
    fi

    # Protect temporary secret files
    chmod 600 "$SECRETS_FILE"

    # Extract secrets and send them into environment variables
    MYSQL_ROOT_PASSWORD=$(grep '^db_root_password=' "$SECRETS_FILE" | cut -d '=' -f2)
    MYSQL_PASSWORD=$(grep '^db_password=' "$SECRETS_FILE" | cut -d '=' -f2)

    # Remove secrets file
    rm "$SECRETS_FILE"

    # Apply Database configuration
    # Create the database if it does not already exist
    mysql --socket="$SOCKET_FILE" -u root -p"$MYSQL_ROOT_PASSWORD" \
        -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" -h localhost

    # Create a new user for database access if it does not already exist
    mysql --socket="$SOCKET_FILE" -u root -p"$MYSQL_ROOT_PASSWORD" \
        -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" -h localhost

    # Grant all privileges on the database to the newly created user
    mysql --socket="$SOCKET_FILE" -u root -p"${MYSQL_ROOT_PASSWORD}" \
        -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" -h localhost

    # Grant root user access from any host with the provided password
    mysql --socket="$SOCKET_FILE" -u root -p"${MYSQL_ROOT_PASSWORD}" \
        -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" -h localhost

    # Ensure the root user is assigned the correct password for localhost authentication
    mysql --socket="$SOCKET_FILE" -u root -p"${MYSQL_ROOT_PASSWORD}" \
        -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" -h localhost

    # Apply all privilege changes to take effect immediately
    mysql --socket="$SOCKET_FILE" -u root -p"${MYSQL_ROOT_PASSWORD}" \
        -e "FLUSH PRIVILEGES;" -h localhost

    # Shutdown MariaDB background process
    mysqladmin --socket="$SOCKET_FILE" -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
    echo "MariaDB shutdown successfully."
)

# Start MariaDB in the foreground
exec mysqld --datadir=${DATA_PATH} --socket=${SOCKET_FILE} --user=mysql --bind-address=0.0.0.0

