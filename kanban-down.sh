#!/bin/bash

# Kanban Docker Compose Down with Automatic Backup
# This script creates a backup before stopping containers

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"
CONTAINER_NAME="kanban-postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="kanban_shutdown_backup_${TIMESTAMP}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Kanban Shutdown with Automatic Backup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if PostgreSQL container is running
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${YELLOW}📦 Creating database backup before shutdown...${NC}"
    
    # Wait for PostgreSQL to be ready
    docker exec "$CONTAINER_NAME" pg_isready -U postgres -d planka 2>/dev/null || true
    
    # Create database dumps
    echo -e "${GREEN}  → Creating PostgreSQL full dump...${NC}"
    docker exec "$CONTAINER_NAME" pg_dumpall -c -U postgres > "$BACKUP_DIR/${BACKUP_NAME}_full.sql" 2>/dev/null || {
        echo -e "${RED}⚠️  Warning: Could not create full dump${NC}"
    }
    
    echo -e "${GREEN}  → Creating Planka database dump...${NC}"
    docker exec "$CONTAINER_NAME" pg_dump -U postgres -d planka --format=custom --compress=9 > "$BACKUP_DIR/${BACKUP_NAME}_planka.dump" 2>/dev/null || {
        echo -e "${RED}⚠️  Warning: Could not create Planka dump${NC}"
    }
    
    # Create backup info file
    cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
Kanban Shutdown Backup Information
===================================
Backup Date: $(date)
Backup Name: $BACKUP_NAME
Trigger: docker-compose down (manual shutdown)
Database: planka
Container: $CONTAINER_NAME

Files:
- ${BACKUP_NAME}_full.sql (full PostgreSQL dump)
- ${BACKUP_NAME}_planka.dump (compressed planka database)

This backup was created before shutting down containers.
It will be automatically restored on next startup.
EOF
    
    # Validate backup has data before compressing
    echo -e "${YELLOW}🔍 Validating backup contains data...${NC}"
    BACKUP_HAS_DATA=false

    # Check if the SQL dump has COPY or INSERT statements (indicating data)
    if grep -q "COPY " "$BACKUP_DIR/${BACKUP_NAME}_full.sql" 2>/dev/null; then
        BACKUP_HAS_DATA=true
        DATA_LINES=$(grep -c "COPY " "$BACKUP_DIR/${BACKUP_NAME}_full.sql" || echo "0")
        echo -e "${GREEN}  ✓ Backup contains data ($DATA_LINES COPY statements)${NC}"
    elif grep -q "INSERT INTO" "$BACKUP_DIR/${BACKUP_NAME}_full.sql" 2>/dev/null; then
        BACKUP_HAS_DATA=true
        DATA_LINES=$(grep -c "INSERT INTO" "$BACKUP_DIR/${BACKUP_NAME}_full.sql" || echo "0")
        echo -e "${GREEN}  ✓ Backup contains data ($DATA_LINES INSERT statements)${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Warning: Backup appears to contain no data (empty database)${NC}"
    fi

    # Compress backup files
    cd "$BACKUP_DIR"
    if tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_info.txt 2>/dev/null; then
        rm -f "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_info.txt

        # Calculate backup size
        BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
        echo -e "${GREEN}✅ Backup created: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE})${NC}"

        # Only update the latest symlink if the backup contains data
        # This prevents empty backups from overwriting good backups
        if [ "$BACKUP_HAS_DATA" = true ]; then
            ln -sf "${BACKUP_NAME}.tar.gz" "LATEST_SHUTDOWN_BACKUP.tar.gz"
            echo -e "${GREEN}  → Marked as latest shutdown backup${NC}"
        else
            echo -e "${YELLOW}  ⚠️  Not marking as latest backup (no data) - keeping previous backup${NC}"
            echo -e "${YELLOW}  ℹ️  Backup saved but LATEST_SHUTDOWN_BACKUP symlink unchanged${NC}"
        fi
    else
        echo -e "${RED}⚠️  Warning: Could not compress backup files${NC}"
    fi
    
    # Keep only last 10 shutdown backups
    ls -t kanban_shutdown_backup_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f
    echo -e "${GREEN}🧹 Cleaned old backups (keeping last 10)${NC}"
else
    echo -e "${YELLOW}ℹ️  PostgreSQL container not running, skipping backup${NC}"
fi

# Now stop all containers
echo -e "${YELLOW}🛑 Stopping all containers...${NC}"
cd "$SCRIPT_DIR"

# Check if --volumes flag was passed or if we should remove volumes
REMOVE_VOLUMES=false
for arg in "$@"; do
    if [[ "$arg" == "--volumes" ]] || [[ "$arg" == "-v" ]]; then
        REMOVE_VOLUMES=true
        break
    fi
done

# If called from compose.sh or with --volumes, remove volumes too
if [ "$REMOVE_VOLUMES" = true ] || [ "$COMPOSE_RESTART" = "true" ]; then
    echo -e "${YELLOW}🗑️  Removing volumes for clean restart...${NC}"
    docker-compose down --volumes --remove-orphans
else
    docker-compose down "$@"
fi

echo -e "${GREEN}✅ All containers stopped successfully${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📌 Backup saved to: $BACKUP_DIR/${BACKUP_NAME}.tar.gz${NC}"
echo -e "${GREEN}📌 This backup will be automatically restored on next startup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"