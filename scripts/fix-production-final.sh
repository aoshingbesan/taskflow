#!/bin/bash

# Final Production Environment Fix Script
# This script will completely resolve the production environment issues

echo "🔧 Final Production Environment Fix..."

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

# Step 1: Delete and recreate production environment
echo "🔄 Step 1: Recreating production environment..."
az webapp delete --name taskflow-app --resource-group taskflow-rg
sleep 10

# Step 2: Create new production environment
echo "🔄 Step 2: Creating new production environment..."
az webapp create --name taskflow-app --resource-group taskflow-rg --plan taskflow-plan --runtime "PYTHON:3.11"

# Step 3: Configure production environment
echo "🔄 Step 3: Configuring production environment..."

# Set environment variables
az webapp config appsettings set --name taskflow-app --resource-group taskflow-rg --settings \
    WEBSITES_PORT=8000 \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    PYTHONPATH=/home/site/wwwroot \
    SECRET_KEY="your-super-secret-key-change-this-in-production" \
    FLASK_ENV=production \
    FLASK_APP=main_app.py \
    MONGODB_URI="mongodb+srv://aoshingbes:bWcxHfCJdXLSzOhg@taskflow.onmvorc.mongodb.net/taskflow?retryWrites=true&w=majority&appName=taskflow" \
    APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=b4cc771a-edf3-499b-97e8-b9186d0f8f53;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/"

# Set startup command
az webapp config set --name taskflow-app --resource-group taskflow-rg --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 main_app:app"

# Step 4: Trigger deployment
echo "🔄 Step 4: Triggering deployment..."
git add .
git commit -m "fix: final production environment fix"
git push origin main

# Step 5: Wait for deployment
echo "⏳ Step 5: Waiting for deployment to complete..."
sleep 120

# Step 6: Test production environment
echo "✅ Step 6: Testing production environment..."
check_url "https://taskflow-app.azurewebsites.net/health" "Production Health"
check_url "https://taskflow-app.azurewebsites.net/" "Production Main"

# Step 7: Final status report
echo ""
echo "📋 Final Status Report:"
echo "Staging: https://taskflow-staging.azurewebsites.net"
echo "Production: https://taskflow-app.azurewebsites.net"
echo ""
echo "🎯 Production Environment Status:"
curl -s https://taskflow-app.azurewebsites.net/health
echo "" 