#!/bin/bash

# Production Deployment Fix Script for TaskFlow
# This script helps diagnose and fix production deployment issues

set -e

echo "🔍 TaskFlow Production Deployment Diagnostic Tool"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check URL health
check_url() {
    local url=$1
    local name=$2
    echo -n "Checking $name... "
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url/health" 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        print_status "SUCCESS" "$name is healthy"
        return 0
    else
        print_status "ERROR" "$name returned status $response"
        return 1
    fi
}

# Function to check Azure App Service status
check_app_service() {
    local app_name=$1
    local resource_group=$2
    echo -n "Checking $app_name status... "
    state=$(az webapp show --name "$app_name" --resource-group "$resource_group" --query "state" --output tsv 2>/dev/null || echo "Unknown")
    if [ "$state" = "Running" ]; then
        print_status "SUCCESS" "$app_name is running"
        return 0
    else
        print_status "ERROR" "$app_name is in state: $state"
        return 1
    fi
}

# Function to check environment variables
check_env_vars() {
    local app_name=$1
    local resource_group=$2
    echo "Checking environment variables for $app_name..."
    
    # Check critical environment variables
    flask_app=$(az webapp config appsettings list --name "$app_name" --resource-group "$resource_group" --query "[?name=='FLASK_APP'].value" --output tsv 2>/dev/null || echo "")
    mongodb_uri=$(az webapp config appsettings list --name "$app_name" --resource-group "$resource_group" --query "[?name=='MONGODB_URI'].value" --output tsv 2>/dev/null || echo "")
    
    if [ -n "$flask_app" ]; then
        print_status "SUCCESS" "FLASK_APP is set to: $flask_app"
    else
        print_status "ERROR" "FLASK_APP is not set"
    fi
    
    if [ -n "$mongodb_uri" ] && [[ "$mongodb_uri" != *"Request ID"* ]]; then
        print_status "SUCCESS" "MONGODB_URI is configured"
    else
        print_status "ERROR" "MONGODB_URI is not properly configured"
    fi
}

# Function to restart app service
restart_app_service() {
    local app_name=$1
    local resource_group=$2
    echo "Restarting $app_name..."
    az webapp restart --name "$app_name" --resource-group "$resource_group" >/dev/null 2>&1
    print_status "INFO" "Restart initiated for $app_name"
    echo "Waiting 30 seconds for restart to complete..."
    sleep 30
}

# Function to sync production with staging configuration
sync_production_with_staging() {
    echo "Syncing production configuration with staging..."
    
    # Get staging environment variables
    staging_settings=$(az webapp config appsettings list --name "taskflow-staging" --resource-group "taskflow-rg" --output json)
    
    # Apply staging settings to production
    echo "$staging_settings" | az webapp config appsettings set --name "taskflow-app" --resource-group "taskflow-rg" --settings @- >/dev/null 2>&1
    
    print_status "SUCCESS" "Production settings synced with staging"
}

# Function to try manual deployment
try_manual_deployment() {
    echo "Attempting manual deployment to production..."
    
    # Configure deployment from main branch
    az webapp deployment source config --name "taskflow-app" --resource-group "taskflow-rg" \
        --repo-url "https://github.com/aoshingbesan/taskflow.git" \
        --branch "main" \
        --manual-integration >/dev/null 2>&1
    
    print_status "INFO" "Manual deployment configured"
}

# Main diagnostic process
echo "Starting comprehensive diagnostic..."

# Check Azure resources
print_status "INFO" "Checking Azure resources..."
check_app_service "taskflow-staging" "taskflow-rg"
check_app_service "taskflow-app" "taskflow-rg"

# Check environment variables
echo ""
print_status "INFO" "Checking environment variables..."
check_env_vars "taskflow-staging" "taskflow-rg"
check_env_vars "taskflow-app" "taskflow-rg"

# Check application health
echo ""
print_status "INFO" "Checking application health..."
check_url "https://taskflow-staging.azurewebsites.net" "Staging"
check_url "https://taskflow-app.azurewebsites.net" "Production"

# Provide recommendations
echo ""
print_status "INFO" "Diagnostic complete. Recommendations:"

if check_url "https://taskflow-staging.azurewebsites.net" "Staging" >/dev/null 2>&1; then
    if ! check_url "https://taskflow-app.azurewebsites.net" "Production" >/dev/null 2>&1; then
        echo ""
        print_status "WARNING" "Staging is working but production is not. Suggested fixes:"
        echo "1. Sync production configuration with staging"
        echo "2. Restart production app service"
        echo "3. Try manual deployment"
        echo ""
        
        read -p "Would you like to attempt automatic fixes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            print_status "INFO" "Attempting automatic fixes..."
            
            # Sync configuration
            sync_production_with_staging
            
            # Restart production
            restart_app_service "taskflow-app" "taskflow-rg"
            
            # Try manual deployment
            try_manual_deployment
            
            echo ""
            print_status "INFO" "Waiting 60 seconds for changes to take effect..."
            sleep 60
            
            # Check again
            echo ""
            print_status "INFO" "Re-checking production health..."
            check_url "https://taskflow-app.azurewebsites.net" "Production"
        fi
    fi
else
    print_status "ERROR" "Both staging and production are down. Check Azure resources."
fi

echo ""
print_status "INFO" "Diagnostic complete. Check the logs above for issues."
print_status "INFO" "If production is still down, consider:"
echo "1. Checking GitHub Actions for failed deployments"
echo "2. Comparing main vs develop branch differences"
echo "3. Enabling detailed logging for debugging"
echo "4. Manual deployment from develop branch"

echo ""
print_status "INFO" "Useful commands:"
echo "- Check logs: az webapp log show --name taskflow-app --resource-group taskflow-rg"
echo "- Restart: az webapp restart --name taskflow-app --resource-group taskflow-rg"
echo "- Check status: az webapp show --name taskflow-app --resource-group taskflow-rg" 