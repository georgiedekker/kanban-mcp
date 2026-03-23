#!/bin/bash

# Automatic PostgreSQL Backup Script for Container Stop
# This script runs when the postgres container receives a stop signal

set -e

# Configuration
BACKUP_DIR="/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="kanban_auto_backup_$TIMESTAMP"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Auto-backup triggered on container stop...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create database backup
echo -e "${GREEN}📦 Creating database backup...${NC}"
pg_dumpall -c -U postgres > "$BACKUP_DIR/${BACKUP_NAME}_full.sql"
pg_dump -U postgres -d planka --format=custom --compress=9 > "$BACKUP_DIR/${BACKUP_NAME}_planka.dump"

# Create backup info file
cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
Kanban Auto-Backup Information
==============================
Backup Date: $(date)
Backup Name: $BACKUP_NAME
Trigger: Container Stop
Database: planka

Files:
- ${BACKUP_NAME}_full.sql (full PostgreSQL dump)
- ${BACKUP_NAME}_planka.dump (compressed planka database)

To restore: pg_restore -U postgres -d planka < ${BACKUP_NAME}_planka.dump
EOF

# Compress backup
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_info.txt
rm "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_info.txt

# Calculate backup size
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

echo -e "${GREEN}✅ Auto-backup completed: $BACKUP_DIR/${BACKUP_NAME}.tar.gz ($BACKUP_SIZE)${NC}"

# Keep only last 5 auto-backups
ls -t kanban_auto_backup_*.tar.gz | tail -n +6 | xargs -r rm -f

echo -e "${GREEN}🧹 Old backups cleaned up (keeping last 5)${NC}"