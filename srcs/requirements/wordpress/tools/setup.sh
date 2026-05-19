#!/bin/sh

set -e

if [ ! -f /var/www/html/wp-config.php ]; then

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    echo "Configuring wp-config.php with database settings..."

    echo $"WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}"
    echo $"WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}"
    echo $"WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}"
    echo $"WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}"
    echo $"WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}"

    sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/g" /var/www/html/wp-config.php
    sed -i "s/username_here/${WORDPRESS_DB_USER}/g" /var/www/html/wp-config.php
    sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/g" /var/www/html/wp-config.php
    sed -i "s/localhost/${WORDPRESS_DB_HOST}/g" /var/www/html/wp-config.php
fi

chown -R nobody:nobody /var/www/html

exec php-fpm82 -F