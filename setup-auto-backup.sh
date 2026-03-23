#!/bin/bash

# Setup Automated Kanban-MCP Database Backups
# This script sets up cron jobs for regular database backups

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/daily-backup.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔧 Setting up automated Kanban-MCP backups...${NC}"

# Make scripts executable
chmod +x "$SCRIPT_DIR/backup-on-stop.sh"
chmod +x "$SCRIPT_DIR/compose-with-backup.sh"
chmod +x "$SCRIPT_DIR/daily-backup.sh"

# Create cron job for daily backups at 2 AM
CRON_JOB="0 2 * * * cd '$SCRIPT_DIR' && ./daily-backup.sh >> '$SCRIPT_DIR/backups/backup.log' 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "daily-backup.sh"; then
    echo -e "${YELLOW}⚠️  Automated backup already configured${NC}"
else
    # Add cron job
    (crontab -l 2>/dev/null || true; echo "$CRON_JOB") | crontab -
    echo -e "${GREEN}✅ Automated daily backup configured for 2:00 AM${NC}"
fi

# Create backup directory
mkdir -p "$SCRIPT_DIR/backups"

echo -e "${GREEN}📋 Backup System Summary:${NC}"
echo "  📁 Backup Directory: $SCRIPT_DIR/backups"
echo "  🕐 Daily Schedule: 2:00 AM"
echo "  📝 Log File: $SCRIPT_DIR/backups/backup.log"
echo "  🔄 Manual Backup: ./daily-backup.sh"
echo "  🛑 Safe Stop: ./compose-with-backup.sh down"
echo ""
echo -e "${YELLOW}💡 Usage Tips:${NC}"
echo "  - Use './compose-with-backup.sh down' instead of 'docker-compose down'"
echo "  - Use './compose-with-backup.sh restart' for safe restarts"
echo "  - Manual backup: './daily-backup.sh'"
echo "  - Check logs: 'tail -f $SCRIPT_DIR/backups/backup.log'"