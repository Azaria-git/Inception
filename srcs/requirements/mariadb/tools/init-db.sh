#!/bin/bash

# check if the required environment variables are set
if [ -z "$MARIADB_DATABASE" ] || [ -z "$MARIADB_USER" ] || [ -z "$MARIADB_PASSWORD" ] || [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "Error: Missing environment variables. Please set MARIADB_DATABASE, MARIADB_USER, MARIADB_PASSWORD, and MARIADB_ROOT_PASSWORD."
    exit 1
fi

# Initialize the database if it hasn't been initialized yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background to perform initial setup
mysqld_safe --skip-networking &

# Wait for MariaDB to be ready using mysqladmin ping with timeout
mysqladmin ping --silent --wait=30 --connect-timeout=2 > /dev/null 2>&1

# Configuration of the security and creation of users and databases

# Remove anonymous users
mysql -e "DELETE FROM mysql.user WHERE User='';"

# Create the main database
mysql -e "CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE;"

# Create the user and grant privileges
mysql -e "CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';"

# Grant privileges
mysql -e "GRANT ALL PRIVILEGES ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%';"

# Set the root password
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD';"

# Flush privileges to ensure that all changes take effect
mysql -e "FLUSH PRIVILEGES;"

# Shutdown MariaDB after initialization
mysqladmin -u root -p$MARIADB_ROOT_PASSWORD shutdown

# Wait for shutdown to complete
mysqladmin ping --silent --wait=5 --connect-timeout=1 > /dev/null 2>&1 || true

# Start MariaDB in the foreground
exec mysqld_safe