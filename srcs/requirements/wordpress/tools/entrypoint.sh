#!/bin/bash

# Wait for MariaDB to be ready
sleep 5

# Start PHP-FPM
php-fpm7.4 -F
