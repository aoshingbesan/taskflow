#!/bin/bash

# Manual Production Deployment Script
# This script manually deploys the working code to production

set -e

echo "🚀 Manual Production Deployment Script"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

echo "Step 1: Checking current branch..."
CURRENT_BRANCH=$(git branch --show-current)
print_status "INFO" "Current branch: $CURRENT_BRANCH"

echo ""
echo "Step 2: Switching to develop branch..."
git checkout develop
print_status "SUCCESS" "Switched to develop branch"

echo ""
echo "Step 3: Creating deployment package..."
# Create a deployment package
zip -r taskflow-deployment.zip . -x "*.git*" "venv/*" "terraform/*" "tests/*" "*.pyc" "__pycache__/*" "*.log" "*.md" "scripts/*" ".github/*"
print_status "SUCCESS" "Deployment package created: taskflow-deployment.zip"

echo ""
echo "Step 4: Deploying to production..."
az webapp deployment source config-zip --resource-group taskflow-rg --name taskflow-app --src taskflow-deployment.zip
print_status "SUCCESS" "Deployment initiated"

echo ""
echo "Step 5: Waiting for deployment to complete..."
sleep 60

echo ""
echo "Step 6: Checking production health..."
PROD_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://taskflow-app.azurewebsites.net/health)
if [ "$PROD_STATUS" = "200" ]; then
    print_status "SUCCESS" "Production deployment successful!"
    print_status "SUCCESS" "Production URL: https://taskflow-app.azurewebsites.net"
else
    print_status "ERROR" "Production deployment failed. Status: $PROD_STATUS"
    print_status "INFO" "Checking production logs..."
    az webapp log show --name taskflow-app --resource-group taskflow-rg
fi

echo ""
echo "Step 7: Cleaning up..."
rm -f taskflow-deployment.zip
print_status "SUCCESS" "Cleanup completed"

echo ""
echo "Step 8: Switching back to original branch..."
git checkout "$CURRENT_BRANCH"
print_status "SUCCESS" "Switched back to $CURRENT_BRANCH"

echo ""
print_status "INFO" "Manual deployment completed!"
print_status "INFO" "Check production at: https://taskflow-app.azurewebsites.net" 