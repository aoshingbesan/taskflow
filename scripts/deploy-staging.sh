#!/bin/bash

# TaskFlow Staging Deployment Script
# This script deploys the application to the staging environment

set -e  # Exit on any error

echo "🚀 Starting TaskFlow Staging Deployment..."

# Configuration
STAGING_APP_NAME="taskflow-staging"
RESOURCE_GROUP="taskflow-rg"
REGISTRY="ghcr.io"
IMAGE_NAME="aoshingbesan/taskflow"

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

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        error "Azure CLI is not installed. Please install it first."
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install it first."
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        error "Not logged into Azure. Please run 'az login' first."
    fi
    
    log "Prerequisites check passed ✅"
}

# Build Docker image
build_image() {
    log "Building Docker image..."
    
    # Build the image
    docker build -t $IMAGE_NAME:staging .
    
    if [ $? -eq 0 ]; then
        log "Docker image built successfully ✅"
    else
        error "Failed to build Docker image"
    fi
}

# Push image to registry
push_image() {
    log "Pushing image to registry..."
    
    # Tag the image
    docker tag $IMAGE_NAME:staging $REGISTRY/$IMAGE_NAME:staging
    
    # Push to registry
    docker push $REGISTRY/$IMAGE_NAME:staging
    
    if [ $? -eq 0 ]; then
        log "Image pushed successfully ✅"
    else
        error "Failed to push image to registry"
    fi
}

# Deploy to staging
deploy_staging() {
    log "Deploying to staging environment..."
    
    # Get the latest image
    IMAGE_URL="$REGISTRY/$IMAGE_NAME:staging"
    
    # Update the app service with the new image
    az webapp config container set \
        --resource-group $RESOURCE_GROUP \
        --name $STAGING_APP_NAME \
        --docker-custom-image-name $IMAGE_URL
    
    if [ $? -eq 0 ]; then
        log "Staging deployment initiated ✅"
    else
        error "Failed to deploy to staging"
    fi
}

# Health check
health_check() {
    log "Performing health check..."
    
    # Wait for deployment to complete
    sleep 30
    
    # Check if the app is responding
    STAGING_URL="https://$STAGING_APP_NAME.azurewebsites.net"
    
    for i in {1..10}; do
        log "Health check attempt $i/10..."
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $STAGING_URL/health)
        
        if [ "$HTTP_STATUS" = "200" ]; then
            log "Health check passed ✅"
            log "Staging URL: $STAGING_URL"
            return 0
        else
            warning "Health check failed (HTTP $HTTP_STATUS), retrying..."
            sleep 10
        fi
    done
    
    error "Health check failed after 10 attempts"
}

# Run tests
run_tests() {
    log "Running tests..."
    
    # Run unit tests
    python -m pytest tests/ -v
    
    if [ $? -eq 0 ]; then
        log "Tests passed ✅"
    else
        error "Tests failed"
    fi
}

# Security scan
security_scan() {
    log "Running security scans..."
    
    # Run Safety (dependency vulnerability scan)
    safety check --json --output safety-report.json || warning "Safety scan completed with warnings"
    
    # Run Bandit (security linting)
    bandit -r app/ -f json -o bandit-report.json || warning "Bandit scan completed with warnings"
    
    log "Security scans completed ✅"
}

# Main deployment process
main() {
    log "Starting TaskFlow staging deployment..."
    
    # Run all deployment steps
    check_prerequisites
    security_scan
    run_tests
    build_image
    push_image
    deploy_staging
    health_check
    
    log "🎉 Staging deployment completed successfully!"
    log "📊 Staging URL: https://$STAGING_APP_NAME.azurewebsites.net"
    log "📋 Health Check: https://$STAGING_APP_NAME.azurewebsites.net/health"
    log "📚 API Docs: https://$STAGING_APP_NAME.azurewebsites.net/docs"
}

# Run main function
main "$@" 