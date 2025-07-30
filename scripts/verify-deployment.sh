#!/bin/bash

# TaskFlow Deployment Verification Script
# This script verifies that the deployment pipeline is working correctly

set -e

echo "🚀 TaskFlow Deployment Verification"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check URL
check_url() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    echo -n "Checking $name... "
    
    # Get HTTP status code
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✅ OK (Status: $status)${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED (Status: $status, Expected: $expected_status)${NC}"
        return 1
    fi
}

# Function to check JSON response
check_json() {
    local url=$1
    local name=$2
    local expected_field=$3
    
    echo -n "Checking $name JSON response... "
    
    # Get JSON response
    response=$(curl -s "$url")
    
    if echo "$response" | grep -q "$expected_field"; then
        echo -e "${GREEN}✅ OK${NC}"
        echo "   Response: $response"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "   Response: $response"
        return 1
    fi
}

echo ""
echo "📊 Checking Staging Environment..."
echo "--------------------------------"

# Check staging health endpoints
check_url "https://taskflow-staging.azurewebsites.net/health" "Staging Health"
check_json "https://taskflow-staging.azurewebsites.net/health" "Staging Health JSON" "healthy"

check_url "https://taskflow-staging.azurewebsites.net/api/v1/health" "Staging API Health"
check_json "https://taskflow-staging.azurewebsites.net/api/v1/health" "Staging API Health JSON" "healthy"

# Check staging documentation
check_url "https://taskflow-staging.azurewebsites.net/docs" "Staging Swagger Docs"

echo ""
echo "📊 Checking Production Environment..."
echo "-----------------------------------"

# Check production health endpoints
check_url "https://taskflow-app.azurewebsites.net/health" "Production Health"
check_json "https://taskflow-app.azurewebsites.net/health" "Production Health JSON" "healthy"

check_url "https://taskflow-app.azurewebsites.net/api/v1/health" "Production API Health"
check_json "https://taskflow-app.azurewebsites.net/api/v1/health" "Production API Health JSON" "healthy"

# Check production documentation
check_url "https://taskflow-app.azurewebsites.net/docs" "Production Swagger Docs"

echo ""
echo "🔍 Testing Authentication Flow..."
echo "-------------------------------"

# Test that protected endpoints redirect to login
check_url "https://taskflow-staging.azurewebsites.net/api/v1/tasks" "Staging Tasks (Protected)" "302"
check_url "https://taskflow-app.azurewebsites.net/api/v1/tasks" "Production Tasks (Protected)" "302"

echo ""
echo "📋 Deployment Summary"
echo "===================="

echo -e "${GREEN}✅ Staging Environment: https://taskflow-staging.azurewebsites.net${NC}"
echo -e "${GREEN}✅ Production Environment: https://taskflow-app.azurewebsites.net${NC}"
echo -e "${GREEN}✅ API Documentation: https://taskflow-app.azurewebsites.net/docs${NC}"

echo ""
echo "🎯 Next Steps:"
echo "1. Monitor GitHub Actions for deployment progress"
echo "2. Test user registration and login functionality"
echo "3. Create and manage tasks through the web interface"
echo "4. Set up MongoDB Atlas for database functionality"

echo ""
echo -e "${GREEN}🚀 TaskFlow Deployment Verification Complete!${NC}" 