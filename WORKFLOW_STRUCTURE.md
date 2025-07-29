# GitHub Actions Workflow Structure

## Overview

The deployment pipeline has been separated into three distinct workflows for better control and organization:

## 📋 Workflow Files

### 1. **Continuous Integration (CI) Pipeline**
**File:** `.github/workflows/ci.yml`
**Purpose:** Basic CI checks for all branches
**Triggers:**
- Push to any branch
- Pull requests to any branch

**Jobs:**
- ✅ Security scanning (Safety, Bandit)
- ✅ Code quality checks (Flake8, Black)
- ✅ Unit testing (Pytest)

### 2. **Staging Deployment Pipeline**
**File:** `.github/workflows/staging-deploy.yml`
**Purpose:** Deploy to staging environment
**Triggers:**
- Push to `develop` branch
- Pull requests to `develop` branch

**Jobs:**
- ✅ Security scanning
- ✅ Code quality checks
- ✅ Unit testing
- ✅ Docker image building (staging tags)
- ✅ Deploy to `taskflow-staging` Azure App Service
- ✅ Health checks for staging environment

### 3. **Production Deployment Pipeline**
**File:** `.github/workflows/production-deploy.yml`
**Purpose:** Deploy to production environment
**Triggers:**
- Pull requests to `main` branch
- Successful completion of staging deployment

**Jobs:**
- ✅ Security scanning
- ✅ Code quality checks
- ✅ Unit testing
- ✅ Docker image building (production tags)
- ✅ Deploy to `taskflow-app` Azure App Service
- ✅ Health checks for production environment

## 🔄 Workflow Flow

```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Develop       │    │   Main Branch    │    │   Production     │
│   Branch        │    │   (PR)           │    │   Deployment     │
│                 │    │                  │    │                  │
│ Push to         │───▶│ Pull Request     │───▶│ Deploy to        │
│ develop         │    │ to main          │    │ taskflow-app     │
│                 │    │                  │    │                  │
│ Deploy to       │    │                  │    │ Health Checks    │
│ taskflow-staging│    │                  │    │                  │
└─────────────────┘    └──────────────────┘    └──────────────────┘
```

## 🎯 Deployment Strategy

### **Staging Environment**
- **Branch:** `develop`
- **Trigger:** Push to develop branch
- **Target:** `taskflow-staging.azurewebsites.net`
- **Purpose:** Testing and validation

### **Production Environment**
- **Branch:** `main`
- **Trigger:** Pull request to main branch
- **Target:** `taskflow-app.azurewebsites.net`
- **Purpose:** Live production environment

## 🔐 Required Secrets

### **For Staging:**
- `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING`

### **For Production:**
- `AZURE_WEBAPP_PUBLISH_PROFILE`

### **For Container Registry:**
- `GITHUB_TOKEN` (automatically provided)

## 🚀 How to Use

### **For Development:**
1. Create a feature branch from `develop`
2. Make your changes
3. Push to `develop` branch
4. Staging deployment will automatically trigger

### **For Production:**
1. Create a pull request from `develop` to `main`
2. Review and approve the PR
3. Production deployment will automatically trigger

### **Manual Deployment:**
```bash
# Deploy to staging
./scripts/deploy-azure.sh

# Set environment variables first:
export AZURE_WEBAPP_NAME="taskflow-staging"
export AZURE_WEBAPP_PUBLISH_PROFILE="your-publish-profile"
```

## 📊 Monitoring

### **Health Endpoints:**
- Staging: `https://taskflow-staging.azurewebsites.net/health`
- Production: `https://taskflow-app.azurewebsites.net/health`

### **Expected Response:**
```json
{
  "status": "healthy",
  "message": "TaskFlow is running!"
}
```

## 🔧 Benefits of This Structure

1. **Separation of Concerns:** CI, staging, and production are separate
2. **Better Control:** Different triggers for different environments
3. **Safety:** Production only deploys on PR approval
4. **Testing:** Staging environment for validation
5. **Monitoring:** Dedicated health checks for each environment

## 🛠️ Troubleshooting

### **If Staging Fails:**
1. Check Azure App Service logs
2. Verify environment variables
3. Test health endpoint manually
4. Review GitHub Actions logs

### **If Production Fails:**
1. Ensure staging is healthy first
2. Check PR approval status
3. Verify production secrets
4. Review deployment logs

## 📝 Notes

- All workflows include security scanning and code quality checks
- Docker images are tagged appropriately for each environment
- Health checks run after each deployment
- Failed deployments will not proceed to the next environment 