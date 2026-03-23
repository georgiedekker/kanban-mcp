#!/bin/bash

# Kanban Docker Compose Up with Automatic Restore
# This script starts containers and ensures data is restored

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Kanban Startup with Automatic Restore${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

# Check for backups
echo -e "${YELLOW}🔍 Checking for available backups...${NC}"

# Look for the latest shutdown backup first
LATEST_BACKUP=""
if [ -L "$BACKUP_DIR/LATEST_SHUTDOWN_BACKUP.tar.gz" ]; then
    LATEST_BACKUP="$BACKUP_DIR/LATEST_SHUTDOWN_BACKUP.tar.gz"
    echo -e "${GREEN}  → Found latest shutdown backup${NC}"
else
    # Fall back to most recent backup
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/kanban_*.tar.gz 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ]; then
        echo -e "${GREEN}  → Found backup: $(basename "$LATEST_BACKUP")${NC}"
    fi
fi

if [ -n "$LATEST_BACKUP" ]; then
    # Extract backup info if available
    TEMP_DIR=$(mktemp -d)
    tar -xzf "$LATEST_BACKUP" -C "$TEMP_DIR" 2>/dev/null || true
    INFO_FILE=$(find "$TEMP_DIR" -name "*_info.txt" -type f | head -1)
    if [ -n "$INFO_FILE" ]; then
        echo -e "${BLUE}📋 Backup Information:${NC}"
        grep -E "Backup Date:|Backup Name:" "$INFO_FILE" | sed 's/^/  /'
    fi
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✅ Backup ready for automatic restore${NC}"
else
    echo -e "${YELLOW}⚠️  No backups found. Database will start fresh.${NC}"
fi

# Start containers
echo -e "${YELLOW}🚀 Starting containers...${NC}"
cd "$SCRIPT_DIR"
docker-compose up -d "$@"

# Wait for Kanban application to initialize
echo -e "${YELLOW}⏳ Waiting for Kanban application to initialize...${NC}"
COUNTER=0
MAX_WAIT=30
while [ $COUNTER -lt $MAX_WAIT ]; do
    # Check if the kanban container is healthy
    if docker inspect kanban --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
        echo -e "${GREEN}✅ Kanban application is ready${NC}"
        break
    fi
    sleep 1
    COUNTER=$((COUNTER + 1))
    if [ $((COUNTER % 10)) -eq 0 ]; then
        echo -e "${YELLOW}  Still waiting... ($COUNTER/$MAX_WAIT seconds)${NC}"
    fi
done

if [ $COUNTER -eq $MAX_WAIT ]; then
    echo -e "${YELLOW}⚠️  Kanban application is still starting (this is normal)${NC}"
fi

# Check database connection from kanban container
echo -e "${YELLOW}📊 Checking database status...${NC}"
DB_CHECK=$(docker exec kanban node -e "const { Client } = require('pg'); const client = new Client({ connectionString: process.env.DATABASE_URL }); client.connect().then(() => client.query('SELECT current_database(), count(*) as table_count FROM information_schema.tables WHERE table_schema=\\'public\\'')).then(r => { console.log(JSON.stringify(r.rows)); client.end(); }).catch(e => { console.error('ERROR'); process.exit(1); });" 2>&1)

if echo "$DB_CHECK" | grep -q "ERROR"; then
    echo -e "${RED}⚠️  Unable to connect to external PostgreSQL database${NC}"
    echo -e "${YELLOW}  Check that postgres.internal (192.168.0.245:6432) is accessible${NC}"
else
    # Parse the table count from the JSON response
    TABLE_COUNT=$(echo "$DB_CHECK" | grep -o '"table_count":"[0-9]*"' | grep -o '[0-9]*' || echo "0")
    DB_NAME=$(echo "$DB_CHECK" | grep -o '"current_database":"[^"]*"' | sed 's/"current_database":"\([^"]*\)"/\1/' || echo "unknown")

    if [ "$TABLE_COUNT" -gt "0" ]; then
        echo -e "${GREEN}✅ Database '$DB_NAME' is connected with $TABLE_COUNT tables${NC}"

        # Show some statistics
        echo -e "${BLUE}📈 Database Statistics:${NC}"
        docker exec kanban node -e "const { Client } = require('pg'); const client = new Client({ connectionString: process.env.DATABASE_URL }); client.connect().then(() => client.query(\`
            SELECT 'Users' as entity, COUNT(*)::text as count FROM user_account
            UNION ALL
            SELECT 'Projects', COUNT(*)::text FROM project
            UNION ALL
            SELECT 'Boards', COUNT(*)::text FROM board
            UNION ALL
            SELECT 'Cards', COUNT(*)::text FROM card
        \`)).then(r => { r.rows.forEach(row => console.log('  ' + row.entity + ': ' + row.count)); client.end(); }).catch(e => { console.error('  Unable to fetch statistics'); client.end(); });" 2>/dev/null || echo "  Unable to fetch statistics"
    else
        echo -e "${YELLOW}⚠️  Database exists but appears empty${NC}"
    fi
fi

# Wait for Kanban service
echo -e "${YELLOW}⏳ Waiting for Kanban service to be ready...${NC}"
sleep 5

# Check if kanban service is running
if docker ps | grep -q "kanban"; then
    echo -e "${GREEN}✅ Kanban service is running${NC}"
else
    echo -e "${RED}⚠️  Kanban service may not be running properly${NC}"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎯 Startup complete!${NC}"
echo -e "${GREEN}📌 Access Planka at: http://localhost:${PLANKA_PORT:-1337}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"

# Show logs option
echo ""
echo -e "${YELLOW}To view logs, run:${NC}"
echo -e "  docker-compose logs -f"