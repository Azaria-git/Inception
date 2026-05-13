#!/bin/bash

# Start MariaDB temporarily
mysqld_safe --user=mysql &

# Wait until MariaDB is ready
while ! mysqladmin ping --silent; do
    sleep 1
done

# Create database
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

# Create user
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"

# Grant privileges
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"

# Apply changes
mysql -e "FLUSH PRIVILEGES;"

# Stop temporary server
mysqladmin -u root shutdown

# Start MariaDB in foreground
exec mysqld --user=mysql --console