#!/bin/bash

# PostgreSQL Initialization and Auto-Restore Script
# This script runs when the postgres container starts

set -e

# Configuration
BACKUP_DIR="/backup"
DB_NAME="planka"
DB_USER="${POSTGRES_USER:-postgres}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 PostgreSQL Container Initialization${NC}"

# Start PostgreSQL in the background
docker-entrypoint.sh postgres \
  -c max_connections=100 \
  -c shared_buffers=256MB &
PG_PID=$!

# Wait for PostgreSQL to be ready with timeout
echo -e "${YELLOW}⏳ Waiting for PostgreSQL to start...${NC}"
COUNTER=0
MAX_WAIT=30
until pg_isready -U "$DB_USER"; do
  sleep 1
  COUNTER=$((COUNTER + 1))
  if [ $COUNTER -ge $MAX_WAIT ]; then
    echo -e "${YELLOW}⚠️  PostgreSQL took longer than expected to start${NC}"
    break
  fi
done

if pg_isready -U "$DB_USER"; then
  echo -e "${GREEN}✅ PostgreSQL is ready${NC}"
else
  echo -e "${RED}❌ PostgreSQL failed to start properly${NC}"
fi

# Give PostgreSQL a moment to fully initialize
sleep 2

# Check if database exists and has data
DB_EXISTS=$(psql -U "$DB_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null || echo "0")
HAS_DATA=0

if [ "$DB_EXISTS" = "1" ]; then
  # Check if database has tables (indicating it has been initialized)
  TABLE_COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null || echo "0")
  if [ "$TABLE_COUNT" -gt "0" ]; then
    HAS_DATA=1
    echo -e "${GREEN}📊 Database '$DB_NAME' exists with $TABLE_COUNT tables${NC}"
  fi
fi

# If database doesn't exist or is empty, try to restore from latest backup
if [ "$HAS_DATA" -eq 0 ]; then
  echo -e "${YELLOW}🔍 Database is empty or doesn't exist. Checking for backups...${NC}"
  
  # Find the latest backup - prioritize shutdown backups
  LATEST_BACKUP=""
  if [ -L "$BACKUP_DIR/LATEST_SHUTDOWN_BACKUP.tar.gz" ]; then
    LATEST_BACKUP="$BACKUP_DIR/LATEST_SHUTDOWN_BACKUP.tar.gz"
    echo -e "${GREEN}📦 Using latest shutdown backup${NC}"
  else
    # Fall back to most recent backup of any type
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/kanban_*.tar.gz 2>/dev/null | head -1)
  fi
  
  if [ -n "$LATEST_BACKUP" ]; then
    echo -e "${GREEN}📦 Found backup: $(basename "$LATEST_BACKUP")${NC}"
    
    # Create temporary directory for extraction
    TEMP_DIR=$(mktemp -d)
    
    # Extract backup
    echo -e "${YELLOW}📂 Extracting backup...${NC}"
    tar -xzf "$LATEST_BACKUP" -C "$TEMP_DIR"
    
    # Find the backup files
    PLANKA_DUMP=$(find "$TEMP_DIR" -name "*_planka.dump" -type f | head -1)
    FULL_SQL=$(find "$TEMP_DIR" -name "*_full.sql" -type f | head -1)
    
    # Create database if it doesn't exist
    if [ "$DB_EXISTS" != "1" ]; then
      echo -e "${YELLOW}🗄️ Creating database '$DB_NAME'...${NC}"
      createdb -U "$DB_USER" "$DB_NAME" || true
    fi
    
    # Restore from backup - prefer full SQL dump for reliability
    if [ -n "$FULL_SQL" ]; then
      echo -e "${GREEN}🔄 Restoring database from full SQL dump...${NC}"
      # Use full SQL dump which is more reliable and handles schema + data together
      # Redirect stderr to filter out non-critical notices
      psql -U "$DB_USER" -v ON_ERROR_STOP=0 -f "$FULL_SQL" 2>&1 | grep -v "^psql.*NOTICE" || true

      # Verify the restore worked by checking for tables
      TABLE_CHECK=$(psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null || echo "0")
      if [ "$TABLE_CHECK" -gt "0" ]; then
        echo -e "${GREEN}✅ Database restored successfully with $TABLE_CHECK tables${NC}"
      else
        echo -e "${YELLOW}⚠️  Warning: Database may not have restored properly${NC}"
      fi
    elif [ -n "$PLANKA_DUMP" ]; then
      echo -e "${GREEN}🔄 Restoring database from pg_dump format...${NC}"
      # Only use pg_restore as fallback
      pg_restore -U "$DB_USER" -d "$DB_NAME" --no-owner --no-acl -v "$PLANKA_DUMP" 2>&1 | grep -E "(restoring|processing)" || true
      echo -e "${GREEN}✅ Database restored from pg_dump backup${NC}"
    else
      echo -e "${YELLOW}⚠️  No valid backup files found in archive${NC}"
    fi
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    # Show restored data statistics
    echo -e "${GREEN}📊 Restored database statistics:${NC}"

    # Show row counts for key tables
    USER_COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM user_account" 2>/dev/null || echo "0")
    PROJECT_COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM project" 2>/dev/null || echo "0")
    BOARD_COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM board" 2>/dev/null || echo "0")
    CARD_COUNT=$(psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM card" 2>/dev/null || echo "0")

    echo -e "  Users: $USER_COUNT"
    echo -e "  Projects: $PROJECT_COUNT"
    echo -e "  Boards: $BOARD_COUNT"
    echo -e "  Cards: $CARD_COUNT"

    if [ "$USER_COUNT" -eq "0" ] && [ "$PROJECT_COUNT" -eq "0" ]; then
      echo -e "${YELLOW}⚠️  Warning: Restored database appears to be empty${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  No backups found in $BACKUP_DIR${NC}"
    echo -e "${BLUE}ℹ️  Database will be initialized fresh by Planka${NC}"
  fi
else
  echo -e "${GREEN}✅ Database already contains data, skipping restore${NC}"
fi

# Setup signal handler for graceful shutdown with backup
trap '/backup-on-stop.sh; kill $PG_PID; wait $PG_PID; exit 0' TERM

echo -e "${GREEN}🎯 PostgreSQL initialization complete${NC}"

# Wait for the PostgreSQL process
wait $PG_PID