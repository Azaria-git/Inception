# Developer Documentation

## Project Structure

```
/home/azaria/Inception/
├── Makefile                    # Build and management commands
├── README.md                   # Project overview
├── USER_DOC.md                # User guide
├── DEV_DOC.md                 # This file
├── secrets/                    # Credentials (git-ignored)
│   └── credentials.txt
└── srcs/
    ├── .env                   # Environment variables
    ├── docker-compose.yml     # Docker Compose configuration
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── php-fpm.conf
        │   └── tools/
        │       └── entrypoint.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── my.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── tools/              # Shared utilities
        └── bonus/              # Optional services
```

## Setup from Scratch

### 1. Prerequisites

- Linux/Unix-based system (VM recommended)
- Docker installed: `docker --version`
- Docker Compose installed: `docker-compose --version`

### 2. Initial Configuration

```bash
# Navigate to project
cd /home/azaria/Inception

# Edit environment variables
nano srcs/.env
```

Update the `.env` file with your configuration:
- Domain name (must use format: `<username>.42.fr`)
- Database credentials
- WordPress admin credentials

### 3. Build the Project

```bash
# Build all Docker images
docker-compose -f srcs/docker-compose.yml build

# Or use the Makefile
make up
```

### 4. Verify Installation

```bash
# Check running containers
docker ps

# You should see:
# - nginx
# - wordpress
# - mariadb

# Check logs
docker logs nginx
docker logs wordpress
docker logs mariadb
```

## Docker Compose Configuration

The `docker-compose.yml` defines:

### Services:
1. **nginx**: Web server, listens on port 443
2. **wordpress**: PHP-FPM application server, exposes port 9000
3. **mariadb**: Database server, exposes port 3306

### Volumes:
- `wordpress_volume`: WordPress files at `/home/azaria/data/wordpress`
- `mariadb_volume`: Database at `/home/azaria/data/mariadb`

### Network:
- `inception_network`: Bridge network connecting all services

## Container Management

### Build Images

```bash
# Build all images
docker-compose -f srcs/docker-compose.yml build

# Build specific service
docker-compose -f srcs/docker-compose.yml build nginx
```

### Start/Stop Containers

```bash
# Start all services
docker-compose -f srcs/docker-compose.yml up -d

# Stop all services
docker-compose -f srcs/docker-compose.yml down

# View logs
docker-compose -f srcs/docker-compose.yml logs -f
```

### Access Container

```bash
# Interactive bash shell
docker exec -it <service_name> /bin/bash

# Execute command
docker exec <service_name> <command>

# Example: Check WordPress files
docker exec wordpress ls -la /var/www/html
```

## Volume Management

### View Volumes

```bash
docker volume ls
docker volume inspect inception_wordpress_volume
docker volume inspect inception_mariadb_volume
```

### Data Locations

**Host Machine:**
- WordPress: `/home/azaria/data/wordpress`
- Database: `/home/azaria/data/mariadb`

**Inside Containers:**
- WordPress: `/var/www/html`
- MariaDB: `/var/lib/mysql`

### Backup Data

```bash
# Backup WordPress files
tar -czf wordpress_backup.tar.gz /home/azaria/data/wordpress

# Backup MariaDB
docker exec mariadb mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > db_backup.sql
```

## Debugging

### Check Container Logs

```bash
# View logs
docker logs <container_name>

# Follow logs (real-time)
docker logs -f <container_name>

# Last 100 lines
docker logs --tail 100 <container_name>
```

### Test Network Connectivity

```bash
# Test from one container to another
docker exec wordpress ping mariadb
docker exec wordpress ping nginx
docker exec nginx ping wordpress
```

### Verify Services

```bash
# Test Nginx
docker exec nginx nginx -t

# Test MariaDB connection
docker exec wordpress mysql -h mariadb -u wordpress_user -p$MYSQL_PASSWORD -e "SELECT 1"

# Test WordPress
docker exec wordpress curl -i http://localhost/wp-admin/
```

## Environment Variables

File: `srcs/.env`

Required variables:
- `DOMAIN_NAME`: Your domain (e.g., azaria.42.fr)
- `MYSQL_DATABASE`: WordPress database name
- `MYSQL_USER`: Database user
- `MYSQL_PASSWORD`: Database password
- `MYSQL_ROOT_PASSWORD`: MariaDB root password
- `WP_ADMIN_USER`: WordPress admin username
- `WP_ADMIN_PASSWORD`: WordPress admin password

## Makefile Targets

```bash
make all          # Default: same as 'make up'
make up           # Start all services
make down         # Stop all services
make clean        # Stop and remove containers
make fclean       # Complete reset (removes data!)
make re           # Restart everything
make logs         # View service logs
```

## Common Issues and Solutions

### Port 443 Already in Use
```bash
# Find what's using port 443
lsof -i :443

# Stop the process or use different port
```

### Database Connection Refused
```bash
# Ensure MariaDB is started
docker logs mariadb

# Check network connectivity
docker exec wordpress ping mariadb
```

### WordPress Files Not Accessible
```bash
# Check file permissions
docker exec wordpress ls -la /var/www/html

# Verify volume mounting
docker inspect wordpress | grep -A 20 Mounts
```

### Container Keeps Restarting
```bash
# Check logs for error
docker logs <container_name>

# Verify entrypoint script
docker exec <container_name> cat /entrypoint.sh
```

## Best Practices

1. **Always use environment variables** - Never hardcode secrets
2. **Named volumes** - Use Docker named volumes, not bind mounts
3. **Don't use latest tag** - Specify exact versions in Dockerfiles
4. **Health checks** - Monitor container health regularly
5. **Logs** - Check logs when troubleshooting
6. **Backups** - Regularly backup data from volumes
7. **Security** - Change all default credentials
8. **Documentation** - Keep setup instructions updated

## Modifications and Testing

To modify services:

1. **Edit Dockerfile** - Update relevant Dockerfile
2. **Rebuild** - `docker-compose build <service>`
3. **Restart** - `docker-compose restart <service>`
4. **Verify** - `docker logs <service>`

Example: Update Nginx configuration
```bash
# Edit file
nano srcs/requirements/nginx/conf/nginx.conf

# Rebuild image
docker-compose -f srcs/docker-compose.yml build nginx

# Restart container
docker-compose -f srcs/docker-compose.yml restart nginx

# Verify
docker logs nginx
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://github.com/compose-spec/compose-spec)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
