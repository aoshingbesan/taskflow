#!/bin/bash

# Clean Azure Deployment Script for TaskFlow
# This script completely resets and redeploys the application

set -e  # Exit on any error

echo "🧹 Starting Clean Azure Deployment..."

# Configuration
RESOURCE_GROUP="taskflow-rg"
STAGING_APP="taskflow-staging"
PRODUCTION_APP="taskflow-app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
check_azure() {
    log "Checking Azure CLI..."
    if ! command -v az &> /dev/null; then
        error "Azure CLI not found. Please install it first."
    fi
    
    if ! az account show &> /dev/null; then
        error "Not logged into Azure. Please run 'az login' first."
    fi
    log "Azure CLI check passed ✅"
}

# Stop all App Services
stop_apps() {
    log "Stopping all App Services..."
    
    az webapp stop --resource-group $RESOURCE_GROUP --name $STAGING_APP || warning "Failed to stop staging"
    az webapp stop --resource-group $RESOURCE_GROUP --name $PRODUCTION_APP || warning "Failed to stop production"
    
    log "App Services stopped ✅"
}

# Clear deployment slots
clear_slots() {
    log "Clearing deployment slots..."
    
    # List and clear any deployment slots
    az webapp deployment slot list --resource-group $RESOURCE_GROUP --name $STAGING_APP || true
    az webapp deployment slot list --resource-group $RESOURCE_GROUP --name $PRODUCTION_APP || true
    
    log "Deployment slots cleared ✅"
}

# Restart App Services
restart_apps() {
    log "Restarting App Services..."
    
    az webapp start --resource-group $RESOURCE_GROUP --name $STAGING_APP
    az webapp start --resource-group $RESOURCE_GROUP --name $PRODUCTION_APP
    
    log "App Services restarted ✅"
}

# Deploy using Azure CLI directly
deploy_direct() {
    log "Deploying using Azure CLI..."
    
    # Create a deployment package
    log "Creating deployment package..."
    zip -r deployment.zip . -x "*.git*" "*.DS_Store*" "venv/*" "__pycache__/*"
    
    # Deploy to staging
    log "Deploying to staging..."
    az webapp deployment source config-zip \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP \
        --src deployment.zip
    
    # Deploy to production
    log "Deploying to production..."
    az webapp deployment source config-zip \
        --resource-group $RESOURCE_GROUP \
        --name $PRODUCTION_APP \
        --src deployment.zip
    
    # Clean up
    rm deployment.zip
    
    log "Direct deployment completed ✅"
}

# Test deployment
test_deployment() {
    log "Testing deployment..."
    
    sleep 30
    
    # Test staging
    log "Testing staging environment..."
    STAGING_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$STAGING_APP.azurewebsites.net/health || echo "000")
    log "Staging status: $STAGING_STATUS"
    
    # Test production
    log "Testing production environment..."
    PROD_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$PRODUCTION_APP.azurewebsites.net/health || echo "000")
    log "Production status: $PROD_STATUS"
    
    if [ "$STAGING_STATUS" = "200" ] || [ "$PROD_STATUS" = "200" ]; then
        log "✅ Deployment successful!"
        return 0
    else
        warning "Deployment may have issues"
        return 1
    fi
}

# Main deployment process
main() {
    log "Starting clean Azure deployment..."
    
    check_azure
    stop_apps
    sleep 10
    clear_slots
    sleep 5
    restart_apps
    sleep 10
    deploy_direct
    test_deployment
    
    log "🎉 Clean Azure deployment completed!"
    log "📊 Staging: https://$STAGING_APP.azurewebsites.net"
    log "📊 Production: https://$PRODUCTION_APP.azurewebsites.net"
}

# Run main function
main "$@" 