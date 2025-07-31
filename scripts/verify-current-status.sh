#!/bin/bash

# TaskFlow Current Status Verification Script
# This script quickly tests the current status of both environments

set -e

echo "🔍 TaskFlow Environment Status Check"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Test staging environment
test_staging() {
    print_status "Testing staging environment (taskflow-staging-new.azurewebsites.net)..."
    
    echo ""
    echo "=== STAGING HEALTH CHECKS ==="
    
    # Test main health endpoint
    echo "1. Main health endpoint:"
    if curl -s -I https://taskflow-staging-new.azurewebsites.net/health | grep -q "200"; then
        print_success "✅ Staging health endpoint: OK"
    else
        print_error "❌ Staging health endpoint: FAILED"
    fi
    
    # Test API health endpoint
    echo "2. API health endpoint:"
    if curl -s -I https://taskflow-staging-new.azurewebsites.net/api/v1/health | grep -q "200"; then
        print_success "✅ Staging API health endpoint: OK"
    else
        print_error "❌ Staging API health endpoint: FAILED"
    fi
    
    # Test main page
    echo "3. Main page:"
    if curl -s -I https://taskflow-staging-new.azurewebsites.net/ | grep -q "200"; then
        print_success "✅ Staging main page: OK"
    else
        print_error "❌ Staging main page: FAILED"
    fi
    
    # Test API docs
    echo "4. API documentation:"
    if curl -s -I https://taskflow-staging-new.azurewebsites.net/docs | grep -q "200"; then
        print_success "✅ Staging API docs: OK"
    else
        print_error "❌ Staging API docs: FAILED"
    fi
}

# Test production environment
test_production() {
    print_status "Testing production environment (taskflow-app-new.azurewebsites.net)..."
    
    echo ""
    echo "=== PRODUCTION HEALTH CHECKS ==="
    
    # Test main health endpoint
    echo "1. Main health endpoint:"
    if curl -s -I https://taskflow-app-new.azurewebsites.net/health | grep -q "200"; then
        print_success "✅ Production health endpoint: OK"
    else
        print_error "❌ Production health endpoint: FAILED"
    fi
    
    # Test API health endpoint
    echo "2. API health endpoint:"
    if curl -s -I https://taskflow-app-new.azurewebsites.net/api/v1/health | grep -q "200"; then
        print_success "✅ Production API health endpoint: OK"
    else
        print_error "❌ Production API health endpoint: FAILED"
    fi
    
    # Test main page
    echo "3. Main page:"
    if curl -s -I https://taskflow-app-new.azurewebsites.net/ | grep -q "200"; then
        print_success "✅ Production main page: OK"
    else
        print_error "❌ Production main page: FAILED"
    fi
    
    # Test API docs
    echo "4. API documentation:"
    if curl -s -I https://taskflow-app-new.azurewebsites.net/docs | grep -q "200"; then
        print_success "✅ Production API docs: OK"
    else
        print_error "❌ Production API docs: FAILED"
    fi
}

# Check Azure CLI and login status
check_azure_cli() {
    print_status "Checking Azure CLI status..."
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed"
        return 1
    fi
    
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure CLI"
        return 1
    fi
    
    print_success "Azure CLI is ready"
    return 0
}

# Get current Azure app status
get_azure_status() {
    if check_azure_cli; then
        echo ""
        echo "=== AZURE APP SERVICE STATUS ==="
        
        echo "Staging app status:"
        az webapp show --name taskflow-staging-new --resource-group taskflow-rg --query "{name:name, state:state, kind:kind, outboundIps:outboundIpAddresses}" --output table 2>/dev/null || print_error "Cannot get staging app status"
        
        echo ""
        echo "Production app status:"
        az webapp show --name taskflow-app-new --resource-group taskflow-rg --query "{name:name, state:state, kind:kind, outboundIps:outboundIpAddresses}" --output table 2>/dev/null || print_error "Cannot get production app status"
    fi
}

# Main execution
main() {
    echo "Starting TaskFlow environment status check..."
    echo ""
    
    # Test both environments
    test_staging
    echo ""
    test_production
    echo ""
    
    # Get Azure status if CLI is available
    get_azure_status
    
    echo ""
    echo "===================================="
    print_status "Status check completed!"
    echo ""
    echo "If any endpoints are failing, run the recovery script:"
    echo "  ./scripts/fix-azure-deployment.sh"
    echo ""
}

# Run main function
main "$@" 