#!/bin/bash

# Initialize MariaDB data directory
mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Start MariaDB
mysqld_safe
