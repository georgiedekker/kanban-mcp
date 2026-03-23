#!/bin/bash

# PostgreSQL Backup Restore Script for Kanban/Planka
# This script restores a backup to the running PostgreSQL container

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
CONTAINER_NAME="kanban-postgres"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to show usage
usage() {
    echo "Usage: $0 [backup_file]"
    echo "If no backup file is specified, the latest backup will be used."
    echo ""
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/kanban_auto_backup_*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
}

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Error: PostgreSQL container '$CONTAINER_NAME' is not running${NC}"
    echo "Please start the containers with: docker-compose up -d"
    exit 1
fi

# Determine backup file
if [ $# -eq 0 ]; then
    # Use latest backup
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/kanban_auto_backup_*.tar.gz 2>/dev/null | head -1)
    if [ -z "$BACKUP_FILE" ]; then
        echo -e "${RED}❌ No backup files found in $BACKUP_DIR${NC}"
        exit 1
    fi
    echo -e "${YELLOW}🔄 Using latest backup: $(basename "$BACKUP_FILE")${NC}"
else
    BACKUP_FILE="$1"
    if [ ! -f "$BACKUP_FILE" ]; then
        # Check if it's just a filename in the backup directory
        if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
            BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
        else
            echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
            usage
        fi
    fi
fi

# Create temporary directory for extraction
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${GREEN}📦 Extracting backup...${NC}"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Find the backup files
PLANKA_DUMP=$(find "$TEMP_DIR" -name "*_planka.dump" -type f | head -1)
FULL_SQL=$(find "$TEMP_DIR" -name "*_full.sql" -type f | head -1)

if [ -z "$PLANKA_DUMP" ] && [ -z "$FULL_SQL" ]; then
    echo -e "${RED}❌ No valid backup files found in archive${NC}"
    exit 1
fi

# Show backup info if available
INFO_FILE=$(find "$TEMP_DIR" -name "*_info.txt" -type f | head -1)
if [ -n "$INFO_FILE" ]; then
    echo -e "${GREEN}📋 Backup Information:${NC}"
    cat "$INFO_FILE"
    echo ""
fi

# Ask for confirmation
echo -e "${YELLOW}⚠️  WARNING: This will replace ALL existing data in the database!${NC}"
read -p "Are you sure you want to restore this backup? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Stop the kanban service to prevent conflicts
echo -e "${GREEN}🛑 Stopping kanban service...${NC}"
docker-compose stop kanban || true

# Wait for PostgreSQL to be ready
echo -e "${GREEN}⏳ Waiting for PostgreSQL to be ready...${NC}"
until docker exec "$CONTAINER_NAME" pg_isready -U postgres -d planka; do
    sleep 1
done

# Restore the database
if [ -n "$PLANKA_DUMP" ]; then
    echo -e "${GREEN}🔄 Restoring planka database from custom format dump...${NC}"
    
    # Drop existing connections
    docker exec "$CONTAINER_NAME" psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'planka' AND pid <> pg_backend_pid();" || true
    
    # Drop and recreate database
    docker exec "$CONTAINER_NAME" psql -U postgres -c "DROP DATABASE IF EXISTS planka;"
    docker exec "$CONTAINER_NAME" psql -U postgres -c "CREATE DATABASE planka;"
    
    # Restore from dump
    docker cp "$PLANKA_DUMP" "$CONTAINER_NAME:/tmp/restore.dump"
    docker exec "$CONTAINER_NAME" pg_restore -U postgres -d planka -c --if-exists /tmp/restore.dump || {
        # If pg_restore fails, try with --no-owner flag
        echo -e "${YELLOW}⚠️  Retrying restore with --no-owner flag...${NC}"
        docker exec "$CONTAINER_NAME" pg_restore -U postgres -d planka -c --if-exists --no-owner /tmp/restore.dump
    }
    docker exec "$CONTAINER_NAME" rm /tmp/restore.dump
    
elif [ -n "$FULL_SQL" ]; then
    echo -e "${GREEN}🔄 Restoring from full SQL dump...${NC}"
    docker cp "$FULL_SQL" "$CONTAINER_NAME:/tmp/restore.sql"
    docker exec "$CONTAINER_NAME" psql -U postgres -f /tmp/restore.sql
    docker exec "$CONTAINER_NAME" rm /tmp/restore.sql
fi

# Start the kanban service again
echo -e "${GREEN}🚀 Starting kanban service...${NC}"
docker-compose up -d kanban

# Wait for service to be ready
echo -e "${GREEN}⏳ Waiting for kanban service to start...${NC}"
sleep 10

echo -e "${GREEN}✅ Restore completed successfully!${NC}"
echo -e "${GREEN}📌 You can now access your Planka instance with your restored data.${NC}"

# Show database statistics
echo -e "${GREEN}📊 Database statistics:${NC}"
docker exec "$CONTAINER_NAME" psql -U postgres -d planka -c "SELECT schemaname, relname as tablename, n_live_tup as row_count FROM pg_stat_user_tables ORDER BY n_live_tup DESC LIMIT 10;"