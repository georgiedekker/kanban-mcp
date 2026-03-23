#!/bin/bash

# Kanban Management Script
# Unified script for managing Kanban containers with automatic backup/restore

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to show usage
show_usage() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}           Kanban Container Management${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC} $0 [command] [options]"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo -e "  ${YELLOW}up${NC}       Start containers (with automatic restore)"
    echo -e "  ${YELLOW}down${NC}     Stop containers (with automatic backup)"
    echo -e "  ${YELLOW}restart${NC}  Restart containers (backup, stop, restore, start)"
    echo -e "  ${YELLOW}status${NC}   Show container status"
    echo -e "  ${YELLOW}logs${NC}     Show container logs"
    echo -e "  ${YELLOW}backup${NC}   Create a manual backup"
    echo -e "  ${YELLOW}restore${NC}  Restore from a specific backup"
    echo -e "  ${YELLOW}list${NC}     List available backups"
    echo -e "  ${YELLOW}help${NC}     Show this help message"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo -e "  $0 up              # Start with auto-restore"
    echo -e "  $0 down            # Stop with auto-backup"
    echo -e "  $0 restart         # Full restart cycle"
    echo -e "  $0 logs -f         # Follow logs"
    echo -e "  $0 backup          # Create manual backup"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

# Function to check container status
check_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}           Container Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    
    echo -e "${YELLOW}🐳 Docker Containers:${NC}"
    docker-compose ps
    
    # Check PostgreSQL
    if docker ps | grep -q "kanban-postgres"; then
        echo ""
        echo -e "${GREEN}✅ PostgreSQL is running${NC}"
        
        # Get database statistics
        DB_EXISTS=$(docker exec kanban-postgres psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='planka'" 2>/dev/null || echo "0")
        if [ "$DB_EXISTS" = "1" ]; then
            echo -e "${BLUE}📊 Database Statistics:${NC}"
            docker exec kanban-postgres psql -U postgres -d planka -c "
                SELECT 'Users' as entity, COUNT(*) as count FROM user_account
                UNION ALL
                SELECT 'Projects', COUNT(*) FROM project
                UNION ALL
                SELECT 'Boards', COUNT(*) FROM board
                UNION ALL
                SELECT 'Cards', COUNT(*) FROM card;
            " 2>/dev/null | grep -v "^(" | head -n 6 || echo "  Unable to fetch statistics"
        fi
    else
        echo -e "${RED}❌ PostgreSQL is not running${NC}"
    fi
    
    # Check Kanban service
    if docker ps | grep -q "kanban"; then
        echo -e "${GREEN}✅ Kanban service is running${NC}"
        echo -e "${GREEN}📌 Access at: http://localhost:${PLANKA_PORT:-1337}${NC}"
    else
        echo -e "${RED}❌ Kanban service is not running${NC}"
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
}

# Function to list backups
list_backups() {
    BACKUP_DIR="${SCRIPT_DIR}/backups"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}           Available Backups${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}📁 Backup Directory: $BACKUP_DIR${NC}"
        echo ""
        
        # Check for latest shutdown backup
        if [ -L "$BACKUP_DIR/LATEST_SHUTDOWN_BACKUP.tar.gz" ]; then
            LATEST=$(readlink "$BACKUP_DIR/LATEST_SHUTDOWN_BACKUP.tar.gz")
            echo -e "${GREEN}⭐ Latest Shutdown Backup: $LATEST${NC}"
            echo ""
        fi
        
        # List all backups
        echo -e "${CYAN}All Backups (newest first):${NC}"
        ls -lht "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -20 | while read line; do
            echo "  $line"
        done
        
        # Count backups
        TOTAL=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
        echo ""
        echo -e "${BLUE}Total backups: $TOTAL${NC}"
    else
        echo -e "${RED}❌ Backup directory not found: $BACKUP_DIR${NC}"
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
}

# Main script logic
cd "$SCRIPT_DIR"

case "${1:-help}" in
    up|start)
        shift
        ./kanban-up.sh "$@"
        ;;
    
    down|stop)
        shift
        ./kanban-down.sh "$@"
        ;;
    
    restart)
        shift
        echo -e "${YELLOW}🔄 Restarting Kanban containers...${NC}"
        ./kanban-down.sh
        sleep 2
        ./kanban-up.sh "$@"
        ;;
    
    status|ps)
        check_status
        ;;
    
    logs|log)
        shift
        docker-compose logs "$@"
        ;;
    
    backup)
        shift
        if [ -f "./daily-backup.sh" ]; then
            ./daily-backup.sh "$@"
        else
            echo -e "${RED}❌ Backup script not found${NC}"
            exit 1
        fi
        ;;
    
    restore)
        shift
        if [ -f "./restore-backup.sh" ]; then
            ./restore-backup.sh "$@"
        else
            echo -e "${RED}❌ Restore script not found${NC}"
            exit 1
        fi
        ;;
    
    list|ls)
        list_backups
        ;;
    
    help|--help|-h|"")
        show_usage
        ;;
    
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac