# TaskFlow Environment Recovery Guide

## 🚨 Emergency Recovery for Non-Working Staging and Production Environments

This guide provides step-by-step instructions to restore your TaskFlow Flask application on Azure App Service when both staging and production environments are down.

## 📋 Prerequisites

- Azure CLI installed and logged in
- Access to your GitHub repository
- MongoDB Atlas connection string
- Azure subscription with contributor access

## 🎯 Quick Diagnosis

First, verify the current status:

```bash
# Test current status
curl -I https://taskflow-staging.azurewebsites.net/health
curl -I https://taskflow-app.azurewebsites.net/health

# Expected: Both should return 200 OK, but currently failing
```

## 🔧 Phase 1: Immediate Azure Configuration Fixes

### Step 1: Run the Recovery Script

The easiest way to apply all fixes is to run the automated recovery script:

```bash
# Make script executable (if not already)
chmod +x scripts/fix-azure-deployment.sh

# Run the recovery script
./scripts/fix-azure-deployment.sh
```

This script will automatically:
- Configure custom startup commands for both environments
- Set proper port configurations
- Configure essential environment variables
- Enable detailed logging
- Restart applications
- Test health endpoints
- Display Azure outbound IPs for MongoDB Atlas

### Step 2: Manual Configuration (Alternative)

If you prefer manual configuration:

```bash
# Configure staging environment
az webapp config set \
  --name taskflow-staging \
  --resource-group taskflow-rg \
  --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 main_app:app"

# Configure production environment  
az webapp config set \
  --name taskflow-app \
  --resource-group taskflow-rg \
  --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 main_app:app"

# Set port for both environments
az webapp config appsettings set \
  --name taskflow-staging \
  --resource-group taskflow-rg \
  --settings WEBSITES_PORT=8000

az webapp config appsettings set \
  --name taskflow-app \
  --resource-group taskflow-rg \
  --settings WEBSITES_PORT=8000

# Configure essential environment variables
az webapp config appsettings set \
  --name taskflow-staging \
  --resource-group taskflow-rg \
  --settings \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    FLASK_ENV=production \
    FLASK_APP=main_app.py \
    PYTHONUNBUFFERED=1

az webapp config appsettings set \
  --name taskflow-app \
  --resource-group taskflow-rg \
  --settings \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    FLASK_ENV=production \
    FLASK_APP=main_app.py \
    PYTHONUNBUFFERED=1

# Enable detailed logging
az webapp log config \
  --name taskflow-staging \
  --resource-group taskflow-rg \
  --docker-container-logging filesystem

az webapp log config \
  --name taskflow-app \
  --resource-group taskflow-rg \
  --docker-container-logging filesystem

# Restart applications
az webapp restart --name taskflow-staging --resource-group taskflow-rg
az webapp restart --name taskflow-app --resource-group taskflow-rg

# Wait for restart to complete
echo "Waiting 60 seconds for applications to restart..."
sleep 60
```

## 💻 Phase 2: Code-Level Fixes (Already Applied)

The following fixes have already been implemented in your codebase:

### ✅ Fix 1: MongoDB Connection Timeouts

**File**: `app/__init__.py`

**Status**: ✅ Already fixed - Connection timeouts updated to 30 seconds

```python
mongoengine.connect(
    host=app.config["MONGODB_URI"], 
    serverSelectionTimeoutMS=30000,  # 30 seconds
    connectTimeoutMS=30000,          # 30 seconds
    socketTimeoutMS=30000            # 30 seconds
)
```

### ✅ Fix 2: Alternative Entry Point

**File**: `app.py` (newly created)

**Status**: ✅ Already created - Alternative entry point for Azure auto-detection

```python
from main_app import app

if __name__ == "__main__":
    import os
    port = int(os.environ.get('PORT', os.environ.get('WEBSITES_PORT', 5000)))
    app.run(host='0.0.0.0', port=port, debug=False)
```

### ✅ Fix 3: Improved Port Handling

**File**: `main_app.py`

**Status**: ✅ Already updated - Robust port detection for Azure environments

```python
if __name__ == '__main__':
    # Handle both Azure and local environments
    port = int(os.environ.get('PORT', os.environ.get('WEBSITES_PORT', 5000)))
    app.run(host='0.0.0.0', port=port, debug=False)
```

### ✅ Fix 4: GitHub Actions Workflow

**Files**: `.github/workflows/staging-deploy.yml` and `.github/workflows/production-deploy.yml`

**Status**: ✅ Already using stable version - `azure/webapps-deploy@v2`

## 🗄️ Phase 3: MongoDB Atlas Connection Fix

### Step 1: Get Azure Outbound IP Addresses

The recovery script will automatically display these, or run manually:

```bash
# Get current outbound IPs for staging
echo "Staging outbound IPs:"
az webapp show --name taskflow-staging --resource-group taskflow-rg --query outboundIpAddresses --output tsv

# Get possible outbound IPs for staging  
echo "Staging possible outbound IPs:"
az webapp show --name taskflow-staging --resource-group taskflow-rg --query possibleOutboundIpAddresses --output tsv

# Get current outbound IPs for production
echo "Production outbound IPs:"
az webapp show --name taskflow-app --resource-group taskflow-rg --query outboundIpAddresses --output tsv

# Get possible outbound IPs for production
echo "Production possible outbound IPs:"
az webapp show --name taskflow-app --resource-group taskflow-rg --query possibleOutboundIpAddresses --output tsv
```

### Step 2: Update MongoDB Atlas Network Access

1. **Log into MongoDB Atlas**
2. **Navigate to Network Access**
3. **Add IP Addresses**:
   - Add ALL IPs from the commands above
   - Include both `outboundIpAddresses` and `possibleOutboundIpAddresses`
   - Use individual IP addresses, not ranges

### Step 3: Verify MongoDB Connection String

```bash
# Check current MongoDB URI (staging)
az webapp config appsettings list --name taskflow-staging --resource-group taskflow-rg --query "[?name=='MONGODB_URI'].value" --output tsv

# Check current MongoDB URI (production)
az webapp config appsettings list --name taskflow-app --resource-group taskflow-rg --query "[?name=='MONGODB_URI'].value" --output tsv
```

## 📊 Phase 4: Deployment and Verification

### Step 1: Commit and Push Code Changes

```bash
# Add all modified files
git add .

# Commit changes
git commit -m "fix: resolve Azure App Service Flask deployment issues

- Update MongoDB connection timeouts (5s -> 30s)
- Add alternative app.py entry point for Azure auto-detection
- Improve port handling for Azure environments
- Downgrade GitHub Actions to azure/webapps-deploy@v2"

# Push to trigger deployments
git push origin main      # Triggers production deployment
git push origin develop   # Triggers staging deployment
```

### Step 2: Monitor Deployment Progress

```bash
# Monitor staging deployment logs
az webapp log tail --name taskflow-staging --resource-group taskflow-rg

# In another terminal, monitor production deployment logs
az webapp log tail --name taskflow-app --resource-group taskflow-rg
```

### Step 3: Final Verification

Wait for deployments to complete (5-10 minutes), then test:

```bash
# Test staging environment
echo "Testing staging environment..."
curl -v https://taskflow-staging.azurewebsites.net/health
curl https://taskflow-staging.azurewebsites.net/api/v1/health

# Test production environment
echo "Testing production environment..."
curl -v https://taskflow-app.azurewebsites.net/health
curl https://taskflow-app.azurewebsites.net/api/v1/health

# Test main pages
curl -I https://taskflow-staging.azurewebsites.net/
curl -I https://taskflow-app.azurewebsites.net/

# Test API documentation
curl -I https://taskflow-staging.azurewebsites.net/docs
curl -I https://taskflow-app.azurewebsites.net/docs
```

## 🔍 Phase 5: Advanced Troubleshooting

If applications are still not working after the above steps:

### Option 1: SSH Diagnosis

```bash
# SSH into staging container
az webapp ssh --name taskflow-staging --resource-group taskflow-rg

# Inside the container, run:
cd /home/site/wwwroot
ls -la
python3 -c "from main_app import app; print('Import successful')"
python3 -c "import mongoengine; print('MongoDB import successful')"
```

### Option 2: Check Kudu Console

Visit these URLs in your browser:
- Staging: `https://taskflow-staging.scm.azurewebsites.net/`
- Production: `https://taskflow-app.scm.azurewebsites.net/`

Navigate to **Debug Console** → **CMD** and verify:
1. Files were deployed correctly
2. Python environment is working
3. Dependencies are installed

### Option 3: Review Application Insights

If configured, check Application Insights for detailed error information:
1. Go to Azure Portal
2. Navigate to Application Insights resource
3. Check **Failures** and **Performance** tabs

## 📈 Expected Recovery Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| Phase 1 | 5-10 minutes | Azure CLI configuration fixes |
| Phase 2 | ✅ Complete | Code changes already applied |
| Phase 3 | 5 minutes | MongoDB Atlas IP whitelist updates |
| Phase 4 | 10-15 minutes | Deployment and verification |
| **Total** | **20-30 minutes** | Complete recovery time |

## ✅ Success Indicators

Your environments are successfully recovered when:

1. **Health Endpoints**: Both return HTTP 200
   - `https://taskflow-staging.azurewebsites.net/health`
   - `https://taskflow-app.azurewebsites.net/health`

2. **API Endpoints**: Both return HTTP 200
   - `https://taskflow-staging.azurewebsites.net/api/v1/health`
   - `https://taskflow-app.azurewebsites.net/api/v1/health`

3. **Main Pages**: Both return HTTP 200
   - `https://taskflow-staging.azurewebsites.net/`
   - `https://taskflow-app.azurewebsites.net/`

4. **API Documentation**: Both return HTTP 200
   - `https://taskflow-staging.azurewebsites.net/docs`
   - `https://taskflow-app.azurewebsites.net/docs`

## 🚨 Emergency Rollback

If issues persist, you can rollback to the last working deployment:

```bash
# List recent deployments
az webapp deployment list --name taskflow-app --resource-group taskflow-rg

# Rollback to specific deployment (replace DEPLOYMENT_ID)
az webapp deployment source delete --name taskflow-app --resource-group taskflow-rg --ids DEPLOYMENT_ID
```

## 📞 Getting Help

If this guide doesn't resolve your issues:

1. **Check Azure Service Health**: https://status.azure.com/
2. **Review GitHub Actions**: Check for failed workflow runs
3. **Azure Support**: Create support ticket if infrastructure issues persist
4. **MongoDB Atlas Support**: Check Atlas status page for connectivity issues

## 📝 Post-Recovery Actions

Once both environments are working:

1. **Monitor Performance**: Watch Application Insights for any degraded performance
2. **Test Functionality**: Verify user registration, login, and task management
3. **Update Documentation**: Record any environment-specific configurations
4. **Set Up Alerts**: Configure monitoring alerts to prevent future outages

## 🎯 Root Cause Summary

The failure was caused by:

1. **Azure Flask Auto-Detection Failure**: `main_app.py` not recognized
2. **Missing Custom Startup Commands**: Required for non-standard entry points
3. **MongoDB Connection Timeouts**: Too short for Azure cold starts
4. **GitHub Actions Regression**: azure/webapps-deploy@v3 issues
5. **MongoDB Atlas IP Whitelist**: Missing Azure outbound IPs

This guide addresses all these root causes systematically to ensure reliable recovery and prevent future occurrences.

## 🚀 Quick Start Commands

For immediate recovery, run these commands in order:

```bash
# 1. Run the automated recovery script
./scripts/fix-azure-deployment.sh

# 2. Add IPs to MongoDB Atlas (manual step)
# Copy the IPs displayed by the script and add them to MongoDB Atlas Network Access

# 3. Commit and push code changes
git add .
git commit -m "fix: resolve Azure App Service deployment issues"
git push origin main
git push origin develop

# 4. Monitor deployments
az webapp log tail --name taskflow-staging --resource-group taskflow-rg
az webapp log tail --name taskflow-app --resource-group taskflow-rg

# 5. Test endpoints
curl https://taskflow-staging.azurewebsites.net/health
curl https://taskflow-app.azurewebsites.net/health
``` 