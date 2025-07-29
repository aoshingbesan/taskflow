#!/bin/bash

# Azure App Service Deployment Script
# This script helps deploy the TaskFlow application to Azure App Service

set -e

echo "🚀 Starting Azure App Service deployment..."

# Check if required environment variables are set
if [ -z "$AZURE_WEBAPP_NAME" ]; then
    echo "❌ Error: AZURE_WEBAPP_NAME environment variable is not set"
    echo "Please set it to your Azure App Service name (e.g., taskflow-staging)"
    exit 1
fi

if [ -z "$AZURE_WEBAPP_PUBLISH_PROFILE" ]; then
    echo "❌ Error: AZURE_WEBAPP_PUBLISH_PROFILE environment variable is not set"
    echo "Please set it to your Azure App Service publish profile"
    exit 1
fi

# Create temporary publish profile file
echo "$AZURE_WEBAPP_PUBLISH_PROFILE" > publish-profile.txt

# Deploy to Azure App Service
echo "📦 Deploying to Azure App Service: $AZURE_WEBAPP_NAME"

# Use Azure CLI to deploy
az webapp deployment source config-zip \
    --resource-group taskflow-rg \
    --name "$AZURE_WEBAPP_NAME" \
    --src . \
    --timeout 1800

# Clean up
rm -f publish-profile.txt

echo "✅ Deployment completed successfully!"
echo "🌐 Your app should be available at: https://$AZURE_WEBAPP_NAME.azurewebsites.net"

# Health check
echo "🔍 Performing health check..."
sleep 30
curl -f "https://$AZURE_WEBAPP_NAME.azurewebsites.net/health" || {
    echo "❌ Health check failed"
    exit 1
}

echo "✅ Health check passed!" 