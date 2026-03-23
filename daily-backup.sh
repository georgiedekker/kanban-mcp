#!/bin/bash

# Daily Kanban-MCP Database Backup Script
# Usage: ./daily-backup.sh

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="kanban_daily_backup_$TIMESTAMP"
CONTAINER_POSTGRES="kanban-postgres"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔄 Starting Kanban-MCP daily backup...${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if containers are running
if ! docker ps | grep -q "$CONTAINER_POSTGRES"; then
    echo -e "${RED}❌ PostgreSQL container '$CONTAINER_POSTGRES' is not running${NC}"
    exit 1
fi

echo -e "${GREEN}📦 Backing up database...${NC}"

# Backup PostgreSQL database
docker exec "$CONTAINER_POSTGRES" pg_dumpall -c -U postgres > "$BACKUP_DIR/${BACKUP_NAME}_full.sql"

# Backup specific planka database with better compression
docker exec "$CONTAINER_POSTGRES" pg_dump -U postgres -d planka --format=custom --compress=9 > "$BACKUP_DIR/${BACKUP_NAME}_planka.dump"

echo -e "${GREEN}📁 Backing up application volumes...${NC}"

# Backup Docker volumes
VOLUMES=("kanban-files" "kanban-user-avatars" "kanban-project-background-images" "kanban-attachments")

for volume in "${VOLUMES[@]}"; do
    echo "  📂 Backing up volume: $volume"
    if docker volume inspect "$volume" >/dev/null 2>&1; then
        docker run --rm -v "$volume:/data" -v "$BACKUP_DIR:/backup" alpine tar czf "/backup/${BACKUP_NAME}_${volume}.tar.gz" -C /data .
    else
        echo -e "${YELLOW}  ⚠️  Volume $volume not found, skipping${NC}"
    fi
done

echo -e "${GREEN}💾 Backing up database volume...${NC}"
# Backup database volume
if docker volume inspect "kanban-db-persistent" >/dev/null 2>&1; then
    docker run --rm -v "kanban-db-persistent:/data" -v "$BACKUP_DIR:/backup" alpine tar czf "/backup/${BACKUP_NAME}_kanban-db-persistent.tar.gz" -C /data .
else
    echo -e "${YELLOW}⚠️  Database volume not found${NC}"
fi

echo -e "${GREEN}⚙️  Saving configuration...${NC}"
# Backup configuration files
if [ -f "$SCRIPT_DIR/docker-compose.yml" ]; then
    cp "$SCRIPT_DIR/docker-compose.yml" "$BACKUP_DIR/${BACKUP_NAME}_docker-compose.yml"
fi

if [ -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env" "$BACKUP_DIR/${BACKUP_NAME}_env"
fi

# Create backup info file
cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
Kanban-MCP Daily Backup Information
====================================
Backup Date: $(date)
Backup Name: $BACKUP_NAME
PostgreSQL Container: $CONTAINER_POSTGRES

Database Backup: ${BACKUP_NAME}_full.sql (full PostgreSQL dump)
Planka DB: ${BACKUP_NAME}_planka.dump (compressed planka database)

Volumes Backed Up:
$(for volume in "${VOLUMES[@]}"; do echo "- ${BACKUP_NAME}_${volume}.tar.gz"; done)
- ${BACKUP_NAME}_kanban-db-persistent.tar.gz

Configuration Files:
- ${BACKUP_NAME}_docker-compose.yml
- ${BACKUP_NAME}_env

To restore this backup:
1. Stop containers: ./compose-with-backup.sh down
2. Restore database: docker exec -i kanban-postgres pg_restore -U postgres -d planka < ${BACKUP_NAME}_planka.dump
3. Restore volumes using docker volume create and docker run commands
4. Start containers: ./compose-with-backup.sh up
EOF

# Create compressed archive of entire backup
echo -e "${GREEN}🗜️  Creating compressed archive...${NC}"
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"_*
rm "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_*.tar.gz "${BACKUP_NAME}"_*.yml "${BACKUP_NAME}"_env "${BACKUP_NAME}"_info.txt 2>/dev/null || true

# Calculate backup size
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

echo -e "${GREEN}✅ Daily backup completed successfully!${NC}"
echo -e "${GREEN}📍 Backup location: $BACKUP_DIR/${BACKUP_NAME}.tar.gz${NC}"
echo -e "${GREEN}📏 Backup size: $BACKUP_SIZE${NC}"

# Clean up old backups (keep last 7 daily backups)
echo -e "${GREEN}🧹 Cleaning up old backups (keeping last 7)...${NC}"
cd "$BACKUP_DIR"
ls -t kanban_daily_backup_*.tar.gz | tail -n +8 | xargs -r rm -f

echo -e "${GREEN}🎉 Daily backup process complete!${NC}"