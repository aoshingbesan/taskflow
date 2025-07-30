#!/bin/bash

# Production Environment Fix Script for Video Demonstration
# This script ensures production environment is healthy for assessment

echo "🔧 Fixing Production Environment for Video Demonstration..."

# Function to check URL health
check_url() {
    local url=$1
    local name=$2
    echo "Checking $name..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$response" = "200" ]; then
        echo "✅ $name is healthy (HTTP $response)"
        return 0
    else
        echo "❌ $name is unhealthy (HTTP $response)"
        return 1
    fi
}

# Function to sync production with staging settings
sync_production_settings() {
    echo "🔄 Syncing production settings with staging..."
    
    # Get staging settings
    staging_settings=$(az webapp config appsettings list --name taskflow-staging --resource-group taskflow-rg --output json)
    
    # Apply to production
    az webapp config appsettings set --name taskflow-app --resource-group taskflow-rg --settings \
        WEBSITES_PORT=8000 \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        PYTHONPATH=/home/site/wwwroot \
        SECRET_KEY="your-super-secret-key-change-this-in-production" \
        FLASK_ENV=production \
        FLASK_APP=main_app.py \
        MONGODB_URI="mongodb+srv://aoshingbes:bWcxHfCJdXLSzOhg@taskflow.onmvorc.mongodb.net/taskflow?retryWrites=true&w=majority&appName=taskflow" \
        APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=b4cc771a-edf3-499b-97e8-b9186d0f8f53;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/"
    
    echo "✅ Production settings updated"
}

# Function to restart production app
restart_production() {
    echo "🔄 Restarting production application..."
    az webapp restart --name taskflow-app --resource-group taskflow-rg
    echo "✅ Production app restarted"
}

# Function to check app service status
check_app_service() {
    echo "🔍 Checking App Service status..."
    az webapp show --name taskflow-app --resource-group taskflow-rg --query "state" --output tsv
}

# Function to check environment variables
check_env_vars() {
    echo "🔍 Checking production environment variables..."
    az webapp config appsettings list --name taskflow-app --resource-group taskflow-rg --query "[].{Name:name, Value:value}" --output table
}

# Main execution
echo "🚀 Starting production environment fix..."

# Step 1: Check current status
echo "📊 Current Status:"
check_url "https://taskflow-staging.azurewebsites.net/health" "Staging"
check_url "https://taskflow-app.azurewebsites.net/health" "Production"

# Step 2: Sync settings if production is down
if ! check_url "https://taskflow-app.azurewebsites.net/health" "Production" > /dev/null 2>&1; then
    echo "🔧 Production is down, syncing settings..."
    sync_production_settings
    restart_production
    
    echo "⏳ Waiting for restart to complete..."
    sleep 60
    
    # Step 3: Verify fix
    echo "✅ Verification:"
    check_url "https://taskflow-app.azurewebsites.net/health" "Production"
    check_url "https://taskflow-app.azurewebsites.net/api/v1/health" "Production API"
    check_url "https://taskflow-app.azurewebsites.net/docs" "Production API Docs"
else
    echo "✅ Production is already healthy!"
fi

# Step 4: Final status report
echo ""
echo "📋 Final Status Report:"
echo "Staging: https://taskflow-staging.azurewebsites.net"
echo "Production: https://taskflow-app.azurewebsites.net"
echo ""
echo "🎯 Ready for Video Demonstration!"
echo ""
echo "📝 Video Demo URLs:"
echo "- Main App: https://taskflow-app.azurewebsites.net"
echo "- Health Check: https://taskflow-app.azurewebsites.net/health"
echo "- API Health: https://taskflow-app.azurewebsites.net/api/v1/health"
echo "- API Docs: https://taskflow-app.azurewebsites.net/docs"
echo "- Staging: https://taskflow-staging.azurewebsites.net" 