# User Documentation

## Overview

This is a complete WordPress website infrastructure running in Docker containers. The system provides:
- Secure HTTPS website access via Nginx
- WordPress content management system
- MariaDB database storage

## Getting Started

### Starting the Project

```bash
cd /home/azaria/Inception
make up
```

This will:
1. Create necessary volumes and directories
2. Build all Docker images
3. Start all containers
4. Initialize the database

### Stopping the Project

```bash
make down
```

### Accessing the Website

1. **Access WordPress**: Open your browser and navigate to `https://azaria.42.fr`
2. **Accept SSL Certificate**: Your browser may warn about the self-signed certificate
3. **WordPress Admin Panel**: Add `/wp-admin` to the domain URL

### Credentials

Credentials are stored securely in `/home/azaria/Inception/secrets/credentials.txt`

**Default WordPress Admin:**
- Username: `site_admin`
- Password: (check secrets file)

**Database Access:**
- User: `wordpress_user`
- Password: (check secrets file)
- Root Password: (check secrets file)

## Common Tasks

### Check Service Status

```bash
docker ps
```

To see if all three containers (nginx, wordpress, mariadb) are running.

### View Service Logs

```bash
make logs
```

Or for a specific service:

```bash
docker logs <container_name>
# Example: docker logs nginx
```

### Access Container Shell

```bash
docker exec -it <container_name> /bin/bash
# Example: docker exec -it wordpress /bin/bash
```

## Data Management

### WordPress Files
- Location: `/home/azaria/data/wordpress`
- Contains: WordPress core, themes, plugins, uploads

### Database
- Location: `/home/azaria/data/mariadb`
- Contains: All WordPress database files

### Persistent Data

All data persists in named volumes and is stored locally. If containers are stopped, data remains intact.

## Troubleshooting

### Containers Won't Start
1. Check disk space: `df -h`
2. Check Docker logs: `docker logs <container_name>`
3. Verify ports 443 is not in use: `lsof -i :443`

### Cannot Access Website
1. Ensure all containers are running: `docker ps`
2. Check Nginx configuration: `docker logs nginx`
3. Verify domain name is in `/etc/hosts`

### Database Connection Issues
1. Check MariaDB logs: `docker logs mariadb`
2. Verify WordPress can reach database: `docker exec wordpress ping mariadb`

## Cleanup

### Full Reset (Warning: Deletes all data)

```bash
make fclean
```

This removes:
- All containers
- All volumes
- All data in `/home/azaria/data`

### Partial Cleanup

```bash
make clean
```

This removes containers but preserves data and volumes.

## Security Notes

- SSL certificates are self-signed for local development
- All credentials should be changed before production use
- Never commit credentials to version control
- Use strong, unique passwords for all services
