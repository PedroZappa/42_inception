#!/usr/bin/env bash

# Entrypoint script for WordPress docker image
sed -i '/listen = /c\listen = 9000' /etc/php/7.4/fpm/pool.d/www.conf

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

# Protect temporary secrets.txt file
chmod 600 /run/secrets/secrets.txt

# Extract secrets witrin scope for added sasfety
(
    # set database access variables from decrypted secrets file
	MYSQL_PASSWORD=$(grep 'db_password=' /run/secrets/secrets.txt | cut -d '=' -f2)
	WP_ADMIN_PASSWORD=$(grep 'wp_admin_password=' /run/secrets/secrets.txt | cut -d '=' -f2)
	WP_ADMIN_EMAIL=$(grep 'wp_admin_email=' /run/secrets/secrets.txt | cut -d '=' -f2)
	WP_USER_PASSWORD=$(grep 'wp_user_password=' /run/secrets/secrets.txt | cut -d '=' -f2)
	WP_USER_EMAIL=$(grep 'wp_user_email=' /run/secrets/secrets.txt | cut -d '=' -f2)

	rm /run/secrets/secrets.txt
    echo "Removed secrets temporary file."

    # Download and configure wordpress
    if [ ! -f "wp-config.php" ]; then
        # Download & install wp-cli
        echo "Downloading wordpress..."
		wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
		chmod +x /usr/local/bin/wp
		# Download and configure WordPress database connection
		wp core download --allow-root

        # Wait for MariaDB
        echo "Waiting for MariaDB to be ready..."
		    until mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
            echo "MariaDB is not ready yet. Retrying..."
            sleep 1
        done
        echo "MariaDB is ready."

        # Setup wp-config.php (search & replace)
        cp wp-config-sample.php wp-config.php
        sed -i "s/username_here/$MYSQL_USER/g" wp-config.php
        sed -i "s/password_here/$MYSQL_PASSWORD/g" wp-config.php
        sed -i "s/localhost/$MYSQL_HOST/g" wp-config.php
        sed -i "s/database_name_here/$MYSQL_DATABASE/g" wp-config.php
        sed -i "s/define( 'WP_DEBUG', false )/define( 'WP_DEBUG', true )/g" wp-config.php

        # Install WordPress 
        echo " Installing wordpress to url https://passunca.42.fr"
        wp core install --url="https://passunca.42.fr" --title="Inception" \
            --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASSWORD \
            --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

        # Create user
        echo "Creating user $WP_USER..."
        wp user create $WP_USER $WP_USER_EMAIL --role=author \
            --user_pass=$WP_USER_PASSWORD --allow-root \
            --path=/var/www/html/wordpress
    fi

    # Set ppremissions
    echo "Setting permissions for Wordpress..."
    find /var/www/html/wordpress/wp-content -type d -exec chmod 777 {} \;
    find /var/www/html/wordpress/wp-content -type f -exec chmod 777 {} \;

    echo "Permissions set for Wordpress."
    echo "Get to a WordPress site here : https://passunca.42.fr"
    echo "Get to WordPress Admin Dashboard here : https://passunca.42.fr/wp-admin"
    echo "Get to a (bonus) static site here : https://passunca.42.pt"
    echo "Get to a (bonus) Adminer service : http://localhost:8080"
)

# Start PHP-FPM
echo "Starting PHP-FPM..."
# Configure PHP-FPM
exec php-fpm7.4 -F
echo "PHP-FPM started."
