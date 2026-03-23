#!/bin/bash

# Docker Compose Wrapper with Automatic Backup
# Usage: ./compose-with-backup.sh [down|restart|stop]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to create backup before stopping containers
backup_before_stop() {
    echo -e "${YELLOW}🔄 Creating backup before stopping containers...${NC}"
    
    # Check if postgres container is running
    if ! docker ps | grep -q "kanban-postgres"; then
        echo -e "${YELLOW}⚠️  PostgreSQL container not running, skipping backup${NC}"
        return 0
    fi
    
    # Create backup
    BACKUP_NAME="kanban_prestop_backup_$TIMESTAMP"
    
    echo -e "${GREEN}📦 Backing up database...${NC}"
    docker exec kanban-postgres pg_dumpall -c -U postgres > "$BACKUP_DIR/${BACKUP_NAME}_full.sql"
    docker exec kanban-postgres pg_dump -U postgres -d planka --format=custom --compress=9 > "$BACKUP_DIR/${BACKUP_NAME}_planka.dump"
    
    # Create backup info
    cat > "$BACKUP_DIR/${BACKUP_NAME}_info.txt" << EOF
Kanban Pre-Stop Backup Information
===================================
Backup Date: $(date)
Backup Name: $BACKUP_NAME
Trigger: Pre-Stop (before docker-compose $1)
Database: planka

Files:
- ${BACKUP_NAME}_full.sql (full PostgreSQL dump)
- ${BACKUP_NAME}_planka.dump (compressed planka database)

To restore: docker exec -i kanban-postgres pg_restore -U postgres -d planka < ${BACKUP_NAME}_planka.dump
EOF
    
    # Compress backup
    cd "$BACKUP_DIR"
    tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_info.txt
    rm "${BACKUP_NAME}"_*.sql "${BACKUP_NAME}"_*.dump "${BACKUP_NAME}"_info.txt
    
    # Calculate backup size
    BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
    
    echo -e "${GREEN}✅ Pre-stop backup completed: $BACKUP_DIR/${BACKUP_NAME}.tar.gz ($BACKUP_SIZE)${NC}"
    
    # Keep only last 10 pre-stop backups
    ls -t kanban_prestop_backup_*.tar.gz | tail -n +11 | xargs -r rm -f
}

# Main script logic
case "$1" in
    "down")
        backup_before_stop "down"
        echo -e "${YELLOW}🛑 Stopping containers...${NC}"
        cd "$SCRIPT_DIR"
        docker-compose down
        echo -e "${GREEN}✅ Containers stopped and backed up${NC}"
        ;;
    "stop")
        backup_before_stop "stop"
        echo -e "${YELLOW}🛑 Stopping containers...${NC}"
        cd "$SCRIPT_DIR"
        docker-compose stop
        echo -e "${GREEN}✅ Containers stopped and backed up${NC}"
        ;;
    "restart")
        backup_before_stop "restart"
        echo -e "${YELLOW}🔄 Restarting containers...${NC}"
        cd "$SCRIPT_DIR"
        docker-compose restart
        echo -e "${GREEN}✅ Containers restarted with backup${NC}"
        ;;
    "up")
        echo -e "${GREEN}🚀 Starting containers...${NC}"
        cd "$SCRIPT_DIR"
        docker-compose up -d
        echo -e "${GREEN}✅ Containers started${NC}"
        ;;
    *)
        echo -e "${RED}Usage: $0 [down|stop|restart|up]${NC}"
        echo ""
        echo "This script automatically creates a backup before stopping containers."
        echo ""
        echo "Commands:"
        echo "  down     - Backup database then run docker-compose down"
        echo "  stop     - Backup database then run docker-compose stop"
        echo "  restart  - Backup database then run docker-compose restart"
        echo "  up       - Run docker-compose up -d (no backup needed)"
        echo ""
        echo "Backups are stored in: $BACKUP_DIR"
        exit 1
        ;;
esac