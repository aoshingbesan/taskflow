#!/bin/bash

# Azure Infrastructure Setup Script for TaskFlow
# This script creates the necessary Azure resources for deployment

set -e

echo "🚀 Setting up Azure infrastructure for TaskFlow..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "🔐 Please login to Azure first:"
    az login
fi

# Set variables
RESOURCE_GROUP="taskflow-rg"
LOCATION="eastus"
APP_SERVICE_PLAN="taskflow-plan"
STAGING_APP="taskflow-staging"
PRODUCTION_APP="taskflow-app"

echo "📋 Creating Azure resources..."

# Create resource group
echo "Creating resource group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create App Service Plan
echo "Creating App Service Plan: $APP_SERVICE_PLAN"
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku B1 \
    --is-linux

# Create staging App Service
echo "Creating staging App Service: $STAGING_APP"
az webapp create \
    --name $STAGING_APP \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --runtime "PYTHON:3.11"

# Create production App Service
echo "Creating production App Service: $PRODUCTION_APP"
az webapp create \
    --name $PRODUCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --runtime "PYTHON:3.11"

# Configure staging environment variables
echo "Configuring staging environment variables..."
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $STAGING_APP \
    --settings \
    WEBSITES_PORT=8000 \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    PYTHONPATH=/home/site/wwwroot \
    SECRET_KEY="your-super-secret-key-change-this" \
    FLASK_ENV=production \
    FLASK_APP=main_app.py

# Configure production environment variables
echo "Configuring production environment variables..."
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $PRODUCTION_APP \
    --settings \
    WEBSITES_PORT=8000 \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    PYTHONPATH=/home/site/wwwroot \
    SECRET_KEY="your-super-secret-key-change-this" \
    FLASK_ENV=production \
    FLASK_APP=main_app.py

# Set startup command for both apps
echo "Setting startup commands..."
az webapp config set \
    --resource-group $RESOURCE_GROUP \
    --name $STAGING_APP \
    --startup-file "gunicorn --bind=0.0.0.0 --timeout=600 wsgi:application"

az webapp config set \
    --resource-group $RESOURCE_GROUP \
    --name $PRODUCTION_APP \
    --startup-file "gunicorn --bind=0.0.0.0 --timeout=600 wsgi:application"

echo "✅ Azure infrastructure setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Add MongoDB connection string to environment variables"
echo "2. Create GitHub secrets for deployment"
echo "3. Test deployment by pushing to develop branch"
echo ""
echo "🌐 Your App Services:"
echo "Staging: https://$STAGING_APP.azurewebsites.net"
echo "Production: https://$PRODUCTION_APP.azurewebsites.net" 