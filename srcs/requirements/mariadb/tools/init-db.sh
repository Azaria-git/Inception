#!/bin/bash

# MARIADB_DATABASE
# MARIADB_USER
# MARIADB_PASSWORD
# MARIADB_ROOT_PASSWORD

# Start MariaDB temporarily
mysqld_safe --user=mysql &

# Wait until MariaDB is ready
while ! mysqladmin ping --silent; do
    sleep 1
done

# Create database
mysql -e "CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};"

# Create user
mysql -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

# Grant privileges
mysql -e "GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';"

# Apply changes
mysql -e "FLUSH PRIVILEGES;"

# Stop temporary server
mysqladmin -u root shutdown

# Start MariaDB in foreground
exec mysqld --user=mysql --console