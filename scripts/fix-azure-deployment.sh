#!/bin/bash

# TaskFlow Azure Deployment Recovery Script
# This script fixes common Azure App Service deployment issues

set -e  # Exit on any error

echo "🚀 Starting TaskFlow Azure Deployment Recovery..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed and logged in
check_azure_cli() {
    print_status "Checking Azure CLI installation..."
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    print_status "Checking Azure login status..."
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    print_success "Azure CLI is ready"
}

# Configure staging environment
configure_staging() {
    print_status "Configuring staging environment (taskflow-staging-new)..."
    
    # Set custom startup command
    az webapp config set \
        --name taskflow-staging-new \
        --resource-group taskflow-rg \
        --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 main_app:app" \
        --output none
    
    # Set port configuration
    az webapp config appsettings set \
        --name taskflow-staging-new \
        --resource-group taskflow-rg \
        --settings WEBSITES_PORT=8000 \
        --output none
    
    # Set essential environment variables
    az webapp config appsettings set \
        --name taskflow-staging-new \
        --resource-group taskflow-rg \
        --settings \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        FLASK_ENV=production \
        FLASK_APP=main_app.py \
        PYTHONUNBUFFERED=1 \
        --output none
    
    # Enable detailed logging
    az webapp log config \
        --name taskflow-staging-new \
        --resource-group taskflow-rg \
        --docker-container-logging filesystem \
        --output none
    
    print_success "Staging environment configured"
}

# Configure production environment
configure_production() {
    print_status "Configuring production environment (taskflow-app-new)..."
    
    # Set custom startup command
    az webapp config set \
        --name taskflow-app-new \
        --resource-group taskflow-rg \
        --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 main_app:app" \
        --output none
    
    # Set port configuration
    az webapp config appsettings set \
        --name taskflow-app-new \
        --resource-group taskflow-rg \
        --settings WEBSITES_PORT=8000 \
        --output none
    
    # Set essential environment variables
    az webapp config appsettings set \
        --name taskflow-app-new \
        --resource-group taskflow-rg \
        --settings \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        FLASK_ENV=production \
        FLASK_APP=main_app.py \
        PYTHONUNBUFFERED=1 \
        --output none
    
    # Enable detailed logging
    az webapp log config \
        --name taskflow-app-new \
        --resource-group taskflow-rg \
        --docker-container-logging filesystem \
        --output none
    
    print_success "Production environment configured"
}

# Get Azure outbound IPs for MongoDB Atlas
get_azure_ips() {
    print_status "Getting Azure outbound IP addresses for MongoDB Atlas whitelist..."
    
    echo ""
    echo "=== STAGING ENVIRONMENT IPs ==="
    echo "Current outbound IPs:"
    az webapp show --name taskflow-staging-new --resource-group taskflow-rg --query outboundIpAddresses --output tsv
    
    echo ""
    echo "Possible outbound IPs:"
    az webapp show --name taskflow-staging-new --resource-group taskflow-rg --query possibleOutboundIpAddresses --output tsv
    
    echo ""
    echo "=== PRODUCTION ENVIRONMENT IPs ==="
    echo "Current outbound IPs:"
    az webapp show --name taskflow-app-new --resource-group taskflow-rg --query outboundIpAddresses --output tsv
    
    echo ""
    echo "Possible outbound IPs:"
    az webapp show --name taskflow-app-new --resource-group taskflow-rg --query possibleOutboundIpAddresses --output tsv
    
    echo ""
    print_warning "Please add ALL these IP addresses to your MongoDB Atlas Network Access whitelist"
    print_warning "Go to MongoDB Atlas → Network Access → Add IP Address"
}

# Restart applications
restart_applications() {
    print_status "Restarting applications..."
    
    # Restart staging
    print_status "Restarting staging environment..."
    az webapp restart --name taskflow-staging-new --resource-group taskflow-rg --output none
    
    # Restart production
    print_status "Restarting production environment..."
    az webapp restart --name taskflow-app-new --resource-group taskflow-rg --output none
    
    print_status "Waiting 60 seconds for applications to restart..."
    sleep 60
    
    print_success "Applications restarted"
}

# Test application health
test_applications() {
    print_status "Testing application health..."
    
    echo ""
    echo "=== TESTING STAGING ENVIRONMENT ==="
    echo "Health endpoint:"
    curl -I https://taskflow-staging-new.azurewebsites.net/health || echo "Staging health check failed"
    
    echo ""
    echo "API health endpoint:"
    curl -I https://taskflow-staging-new.azurewebsites.net/api/v1/health || echo "Staging API health check failed"
    
    echo ""
    echo "=== TESTING PRODUCTION ENVIRONMENT ==="
    echo "Health endpoint:"
    curl -I https://taskflow-app-new.azurewebsites.net/health || echo "Production health check failed"
    
    echo ""
    echo "API health endpoint:"
    curl -I https://taskflow-app-new.azurewebsites.net/api/v1/health || echo "Production API health check failed"
    
    echo ""
    print_success "Health checks completed"
}

# Check MongoDB connection strings
check_mongodb_uris() {
    print_status "Checking MongoDB connection strings..."
    
    echo ""
    echo "=== STAGING MONGODB URI ==="
    az webapp config appsettings list --name taskflow-staging-new --resource-group taskflow-rg --query "[?name=='MONGODB_URI'].value" --output tsv
    
    echo ""
    echo "=== PRODUCTION MONGODB URI ==="
    az webapp config appsettings list --name taskflow-app-new --resource-group taskflow-rg --query "[?name=='MONGODB_URI'].value" --output tsv
    
    echo ""
    print_warning "Verify these MongoDB URIs are correct and accessible"
}

# Main execution
main() {
    echo "=========================================="
    echo "TaskFlow Azure Deployment Recovery Script"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    check_azure_cli
    
    # Configure environments
    configure_staging
    configure_production
    
    # Get IP addresses for MongoDB Atlas
    get_azure_ips
    
    # Restart applications
    restart_applications
    
    # Test applications
    test_applications
    
    # Check MongoDB URIs
    check_mongodb_uris
    
    echo ""
    echo "=========================================="
    print_success "Recovery script completed!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Add the IP addresses above to MongoDB Atlas Network Access"
    echo "2. Verify MongoDB connection strings are correct"
    echo "3. Monitor application logs if issues persist:"
    echo "   - Staging: az webapp log tail --name taskflow-staging --resource-group taskflow-rg"
    echo "   - Production: az webapp log tail --name taskflow-app --resource-group taskflow-rg"
    echo ""
}

# Run main function
main "$@" 