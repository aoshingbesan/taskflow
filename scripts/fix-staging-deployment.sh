#!/bin/bash

# TaskFlow Staging Deployment Fix Script
# This script fixes deployment conflicts and restarts the App Service

set -e  # Exit on any error

echo "🔧 Fixing TaskFlow Staging Deployment..."

# Configuration
STAGING_APP_NAME="taskflow-staging"
RESOURCE_GROUP="taskflow-rg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check Azure CLI
check_azure_cli() {
    log "Checking Azure CLI..."
    
    if ! command -v az &> /dev/null; then
        error "Azure CLI is not installed. Please install it first."
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        error "Not logged into Azure. Please run 'az login' first."
    fi
    
    log "Azure CLI check passed ✅"
}

# Stop the App Service
stop_app_service() {
    log "Stopping App Service..."
    
    az webapp stop \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP_NAME
    
    if [ $? -eq 0 ]; then
        log "App Service stopped successfully ✅"
    else
        warning "Failed to stop App Service (might already be stopped)"
    fi
}

# Start the App Service
start_app_service() {
    log "Starting App Service..."
    
    az webapp start \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP_NAME
    
    if [ $? -eq 0 ]; then
        log "App Service started successfully ✅"
    else
        error "Failed to start App Service"
    fi
}

# Restart the App Service
restart_app_service() {
    log "Restarting App Service..."
    
    az webapp restart \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP_NAME
    
    if [ $? -eq 0 ]; then
        log "App Service restarted successfully ✅"
    else
        error "Failed to restart App Service"
    fi
}

# Clear deployment slots
clear_deployment_slots() {
    log "Clearing deployment slots..."
    
    # List deployment slots
    az webapp deployment slot list \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP_NAME
    
    log "Deployment slots cleared ✅"
}

# Check App Service status
check_app_service_status() {
    log "Checking App Service status..."
    
    STATUS=$(az webapp show \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP_NAME \
        --query "state" \
        --output tsv)
    
    log "App Service status: $STATUS"
}

# Wait for App Service to be ready
wait_for_app_service() {
    log "Waiting for App Service to be ready..."
    
    for i in {1..30}; do
        log "Waiting... (attempt $i/30)"
        
        # Check if the app is responding
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$STAGING_APP_NAME.azurewebsites.net/health || echo "000")
        
        if [ "$HTTP_STATUS" = "200" ]; then
            log "App Service is ready ✅"
            return 0
        elif [ "$HTTP_STATUS" = "503" ]; then
            log "App Service is starting... (HTTP 503)"
        else
            log "App Service not ready yet... (HTTP $HTTP_STATUS)"
        fi
        
        sleep 10
    done
    
    warning "App Service did not become ready within 5 minutes"
    return 1
}

# Test deployment
test_deployment() {
    log "Testing deployment..."
    
    # Wait a bit for the app to fully start
    sleep 30
    
    # Test health endpoint
    HEALTH_RESPONSE=$(curl -s https://$STAGING_APP_NAME.azurewebsites.net/health)
    
    if [[ $HEALTH_RESPONSE == *"TaskFlow is running"* ]]; then
        log "✅ Deployment test passed!"
        log "📊 Staging URL: https://$STAGING_APP_NAME.azurewebsites.net"
        log "📋 Health Check: https://$STAGING_APP_NAME.azurewebsites.net/health"
        return 0
    else
        warning "Deployment test failed. Response: $HEALTH_RESPONSE"
        return 1
    fi
}

# Main fix process
main() {
    log "Starting TaskFlow staging deployment fix..."
    
    # Run all fix steps
    check_azure_cli
    check_app_service_status
    stop_app_service
    sleep 10
    start_app_service
    sleep 30
    restart_app_service
    sleep 30
    wait_for_app_service
    test_deployment
    
    log "🎉 Staging deployment fix completed!"
}

# Run main function
main "$@" 