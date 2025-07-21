#!/bin/bash

# TaskFlow Setup Test Script
# This script tests the setup without requiring Docker to be running

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧪 Testing TaskFlow setup...${NC}"

# Test 1: Check if all required files exist
echo -e "${YELLOW}📁 Checking required files...${NC}"

required_files=(
    "Dockerfile"
    "docker-compose.yml"
    "requirements.txt"
    "app.py"
    "config.py"
    "terraform/main.tf"
    "terraform/variables.tf"
    "terraform/terraform.tfvars.example"
    "scripts/deploy.sh"
    "scripts/setup-infrastructure.sh"
    "app/__init__.py"
    "app/models.py"
    "app/routes/main.py"
    "app/routes/auth.py"
    "app/routes/tasks.py"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All required files exist${NC}"
else
    echo -e "${RED}❌ Missing files:${NC}"
    for file in "${missing_files[@]}"; do
        echo -e "${RED}   - $file${NC}"
    done
    exit 1
fi

# Test 2: Check Dockerfile syntax
echo -e "${YELLOW}🐳 Checking Dockerfile...${NC}"
if grep -q "FROM python:3.11-slim" Dockerfile; then
    echo -e "${GREEN}✅ Dockerfile uses correct base image${NC}"
else
    echo -e "${RED}❌ Dockerfile base image issue${NC}"
fi

if grep -q "EXPOSE 8000" Dockerfile; then
    echo -e "${GREEN}✅ Dockerfile exposes correct port${NC}"
else
    echo -e "${RED}❌ Dockerfile port exposure issue${NC}"
fi

# Test 3: Check docker-compose.yml
echo -e "${YELLOW}🐙 Checking docker-compose.yml...${NC}"
if grep -q "version: '3.8'" docker-compose.yml; then
    echo -e "${GREEN}✅ docker-compose.yml has correct version${NC}"
else
    echo -e "${RED}❌ docker-compose.yml version issue${NC}"
fi

if grep -q "postgres:15-alpine" docker-compose.yml; then
    echo -e "${GREEN}✅ docker-compose.yml includes PostgreSQL${NC}"
else
    echo -e "${RED}❌ docker-compose.yml PostgreSQL issue${NC}"
fi

# Test 4: Check Terraform files
echo -e "${YELLOW}🏗️  Checking Terraform files...${NC}"
if [ -f "terraform/main.tf" ] && [ -f "terraform/variables.tf" ]; then
    echo -e "${GREEN}✅ Terraform files exist${NC}"
else
    echo -e "${RED}❌ Terraform files missing${NC}"
fi

# Test 5: Check Python dependencies
echo -e "${YELLOW}🐍 Checking Python dependencies...${NC}"
if grep -q "Flask==" requirements.txt; then
    echo -e "${GREEN}✅ Flask dependency found${NC}"
else
    echo -e "${RED}❌ Flask dependency missing${NC}"
fi

if grep -q "psycopg2-binary==" requirements.txt; then
    echo -e "${GREEN}✅ PostgreSQL dependency found${NC}"
else
    echo -e "${RED}❌ PostgreSQL dependency missing${NC}"
fi

if grep -q "gunicorn==" requirements.txt; then
    echo -e "${GREEN}✅ Gunicorn dependency found${NC}"
else
    echo -e "${RED}❌ Gunicorn dependency missing${NC}"
fi

# Test 6: Check health endpoint
echo -e "${YELLOW}🏥 Checking health endpoint...${NC}"
if grep -q "@main_bp.route(\"/health\")" app/routes/main.py; then
    echo -e "${GREEN}✅ Health endpoint exists${NC}"
else
    echo -e "${RED}❌ Health endpoint missing${NC}"
fi

# Test 7: Check scripts
echo -e "${YELLOW}📜 Checking scripts...${NC}"
if [ -x "scripts/deploy.sh" ]; then
    echo -e "${GREEN}✅ Deploy script is executable${NC}"
else
    echo -e "${RED}❌ Deploy script not executable${NC}"
fi

if [ -x "scripts/setup-infrastructure.sh" ]; then
    echo -e "${GREEN}✅ Infrastructure setup script is executable${NC}"
else
    echo -e "${RED}❌ Infrastructure setup script not executable${NC}"
fi

echo -e "${GREEN}🎉 Setup test completed successfully!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "${YELLOW}   1. Start Docker Desktop${NC}"
echo -e "${YELLOW}   2. Test with: docker-compose up --build${NC}"
echo -e "${YELLOW}   3. Set up AWS credentials${NC}"
echo -e "${YELLOW}   4. Run: ./scripts/setup-infrastructure.sh${NC}" 