#!/bin/bash

# TaskFlow Deployment Monitor
# This script monitors deployment progress and tests applications

set -e

echo "🚀 TaskFlow Deployment Monitor"
echo "=============================="
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

# Test application endpoints
test_endpoint() {
    local url=$1
    local name=$2
    
    echo "Testing $name..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "200" ]; then
        print_success "✅ $name: OK (HTTP $response)"
        return 0
    elif [ "$response" = "503" ]; then
        print_warning "⚠️  $name: Service Unavailable (HTTP $response) - Still deploying"
        return 1
    elif [ "$response" = "403" ]; then
        print_error "❌ $name: Forbidden (HTTP $response) - Site disabled"
        return 1
    else
        print_error "❌ $name: Failed (HTTP $response)"
        return 1
    fi
}

# Monitor deployment
monitor_deployment() {
    print_status "Starting deployment monitoring..."
    echo ""
    
    local attempts=0
    local max_attempts=30
    local success_count=0
    
    while [ $attempts -lt $max_attempts ]; do
        attempts=$((attempts + 1))
        echo "Attempt $attempts/$max_attempts - $(date)"
        echo ""
        
        # Test staging endpoints
        echo "=== STAGING ENVIRONMENT ==="
        test_endpoint "https://taskflow-staging-new.azurewebsites.net/health" "Staging Health"
        staging_health=$?
        
        test_endpoint "https://taskflow-staging-new.azurewebsites.net/api/v1/health" "Staging API Health"
        staging_api=$?
        
        # Test production endpoints
        echo ""
        echo "=== PRODUCTION ENVIRONMENT ==="
        test_endpoint "https://taskflow-app-new.azurewebsites.net/health" "Production Health"
        production_health=$?
        
        test_endpoint "https://taskflow-app-new.azurewebsites.net/api/v1/health" "Production API Health"
        production_api=$?
        
        # Check if all endpoints are working
        if [ $staging_health -eq 0 ] && [ $staging_api -eq 0 ] && [ $production_health -eq 0 ] && [ $production_api -eq 0 ]; then
            success_count=$((success_count + 1))
            if [ $success_count -ge 3 ]; then
                echo ""
                print_success "🎉 All endpoints are working! Deployment successful!"
                echo ""
                echo "✅ Staging: https://taskflow-staging-new.azurewebsites.net"
                echo "✅ Production: https://taskflow-app-new.azurewebsites.net"
                echo ""
                echo "📚 API Documentation:"
                echo "   - Staging: https://taskflow-staging-new.azurewebsites.net/docs"
                echo "   - Production: https://taskflow-app-new.azurewebsites.net/docs"
                return 0
            fi
        else
            success_count=0
        fi
        
        echo ""
        print_status "Waiting 30 seconds before next check..."
        echo "----------------------------------------"
        sleep 30
    done
    
    echo ""
    print_error "❌ Deployment monitoring timed out after $max_attempts attempts"
    print_warning "Check GitHub Actions for deployment status"
    return 1
}

# MongoDB Atlas IP Instructions
show_mongodb_instructions() {
    echo ""
    echo "🗄️  MONGODB ATLAS IP WHITELIST INSTRUCTIONS"
    echo "============================================="
    echo ""
    echo "Add these IP addresses to MongoDB Atlas Network Access:"
    echo ""
    echo "Current Outbound IPs:"
    echo "137.135.68.200"
    echo "40.114.0.237"
    echo "137.135.72.121"
    echo "104.45.154.191"
    echo "104.45.141.247"
    echo ""
    echo "Possible Outbound IPs (add these too):"
    echo "104.41.156.195,104.45.141.247,104.45.154.191,137.117.65.231,137.135.68.200,137.135.69.14,137.135.71.44,137.135.72.121,23.100.31.222,40.114.0.237,52.147.212.183,52.149.202.44,52.149.202.96,52.149.203.51,52.149.204.231,52.154.64.253,52.154.65.138,52.154.65.244,52.154.65.35,52.154.66.155,52.154.66.76,52.154.66.91"
    echo ""
    echo "Steps:"
    echo "1. Go to MongoDB Atlas Dashboard"
    echo "2. Navigate to Network Access"
    echo "3. Click 'Add IP Address'"
    echo "4. Add each IP address individually"
    echo "5. Save changes"
    echo ""
}

# Main execution
main() {
    echo "Starting TaskFlow deployment monitoring..."
    echo ""
    
    # Show MongoDB instructions
    show_mongodb_instructions
    
    # Start monitoring
    monitor_deployment
    
    echo ""
    echo "=========================================="
    print_status "Monitoring completed!"
    echo "=========================================="
}

# Run main function
main "$@" 