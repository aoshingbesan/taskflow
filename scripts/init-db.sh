#!/bin/bash

# Database Initialization Script for TaskFlow
# This script initializes the database in a containerized environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🗄️  Initializing TaskFlow database...${NC}"

# Check if we're in a container environment
if [ -n "$DATABASE_URL" ]; then
    echo -e "${YELLOW}📊 Using production database: ${DATABASE_URL}${NC}"
else
    echo -e "${YELLOW}📊 Using development database${NC}"
fi

# Wait for database to be ready (for containerized environments)
if [ -n "$DATABASE_URL" ]; then
    echo -e "${YELLOW}⏳ Waiting for database to be ready...${NC}"
    
    # Extract database connection details
    if [[ $DATABASE_URL =~ postgresql://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+) ]]; then
        DB_USER="${BASH_REMATCH[1]}"
        DB_PASS="${BASH_REMATCH[2]}"
        DB_HOST="${BASH_REMATCH[3]}"
        DB_PORT="${BASH_REMATCH[4]}"
        DB_NAME="${BASH_REMATCH[5]}"
        
        echo -e "${YELLOW}🔍 Testing database connection...${NC}"
        
        # Wait for database to be available
        until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
            echo -e "${YELLOW}⏳ Database not ready, waiting...${NC}"
            sleep 2
        done
        
        echo -e "${GREEN}✅ Database is ready!${NC}"
    fi
fi

# Initialize database
echo -e "${YELLOW}🔧 Initializing database schema...${NC}"

# Run database migrations
flask db upgrade

echo -e "${GREEN}✅ Database initialization completed!${NC}"
echo -e "${YELLOW}📝 Database is ready for use.${NC}" 