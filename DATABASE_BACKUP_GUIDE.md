# Database Backup and Restore Guide

## Overview
The Kanban/Planka system includes automatic backup functionality that creates backups when the PostgreSQL container is stopped. However, backups are NOT automatically restored when starting the container.

## Automatic Backups
- **Location**: `./backups/`
- **Trigger**: Created automatically when running `docker-compose down`
- **Format**: Compressed tar.gz files containing PostgreSQL dumps
- **Retention**: Last 5 backups are kept automatically

## Manual Restore Process

### Restore Latest Backup
```bash
./restore-backup.sh
```

### Restore Specific Backup
```bash
./restore-backup.sh ./backups/kanban_auto_backup_20250722_182133.tar.gz
```

## Data Persistence

### Volume Information
- **Volume Name**: `kanban-db-persistent`
- **Type**: Named Docker volume
- **Location**: `/var/lib/docker/volumes/kanban-db-persistent/_data`

### Why Data Might Be Lost
1. Running `docker volume prune` or `docker system prune -a --volumes`
2. Manually deleting the volume with `docker volume rm kanban-db-persistent`
3. Docker Desktop reset or reinstallation
4. System disk cleanup tools

### Preventing Data Loss
1. **Never run** `docker volume prune` without checking important volumes first
2. **Use** `docker system prune -a` (without `--volumes` flag) for safe cleanup
3. **Regular backups** are created automatically on container stop
4. **External backups**: Copy `./backups/` to cloud storage periodically

## Manual Backup Commands

### Create Manual Backup (while running)
```bash
docker exec kanban-postgres pg_dump -U postgres -d planka --format=custom --compress=9 > ./backups/manual_backup_$(date +%Y%m%d_%H%M%S).dump
```

### Check Volume Status
```bash
# List all kanban-related volumes
docker volume ls | grep kanban

# Inspect the database volume
docker volume inspect kanban-db-persistent
```

## Troubleshooting

### If restore fails
1. Ensure containers are running: `docker-compose up -d`
2. Check PostgreSQL logs: `docker logs kanban-postgres`
3. Verify backup file integrity: `tar -tzf backup_file.tar.gz`

### Database connection issues after restore
1. Restart all services: `docker-compose restart`
2. Check environment variables in `.env` file
3. Verify database credentials match between backup and current setup