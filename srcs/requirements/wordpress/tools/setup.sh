#!/bin/sh

set -e

if [ ! -f /var/www/html/wp-config.php ]; then

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/${DB_NAME}/g" /var/www/html/wp-config.php
    sed -i "s/username_here/${DB_USER}/g" /var/www/html/wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/g" /var/www/html/wp-config.php
    sed -i "s/localhost/${DB_HOST}/g" /var/www/html/wp-config.php
fi

chown -R nobody:nobody /var/www/html

exec php-fpm82 -F