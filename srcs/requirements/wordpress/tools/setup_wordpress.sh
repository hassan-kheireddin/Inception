#!/bin/bash

set -e

DB_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
WP_ADMIN_PASSWORD=$(cat $WP_ADMIN_PASSWORD_FILE)
WP_USER_PASSWORD=$(cat $WP_USER_PASSWORD_FILE)

DB_HOST=$(echo $MYSQL_HOST | cut -d':' -f1)
DB_PORT=$(echo $MYSQL_HOST | cut -d':' -f2)

until nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do
    sleep 2
done

cd /var/www/html

# Download WordPress if not present
if [ ! -f wp-load.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
fi

# Create config if not present
if [ ! -f wp-config.php ]; then
    echo "Creating WordPress configuration..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    echo "Creating WordPress user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root 2>/dev/null || true
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec php-fpm8.2 -F
