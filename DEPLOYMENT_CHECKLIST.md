# Azure App Service Deployment Checklist

## ✅ Completed Configuration

The following files have been created/updated for Azure App Service deployment:

### Core Deployment Files
- ✅ `.deployment` - Azure App Service deployment configuration
- ✅ `web.config` - IIS configuration for Python hosting
- ✅ `startup.txt` - Application startup command
- ✅ `wsgi.py` - WSGI entry point
- ✅ `main_app.py` - Flask application entry point

### GitHub Actions Workflow
- ✅ `.github/workflows/cd.yml` - Updated for direct deployment (not Docker)
- ✅ Deployment triggers on push to main branch
- ✅ Health checks after deployment

### Dependencies
- ✅ `requirements.txt` - Updated with wfastcgi for Azure compatibility
- ✅ All Python dependencies installed and tested

### Documentation
- ✅ `AZURE_DEPLOYMENT.md` - Comprehensive deployment guide
- ✅ `scripts/deploy-azure.sh` - Manual deployment script
- ✅ `test_deployment.py` - Deployment verification script

## 🔧 Required Azure Configuration

### 1. Azure App Service Setup

Create two App Services in Azure:
- **Staging**: `taskflow-staging`
- **Production**: `taskflow-app`

### 2. Application Settings

Configure these environment variables in Azure App Service:

#### General Settings
```
WEBSITES_PORT=8000
SCM_DO_BUILD_DURING_DEPLOYMENT=true
PYTHONPATH=/home/site/wwwroot
```

#### Flask Settings
```
SECRET_KEY=your-super-secret-key-change-this-in-production
FLASK_ENV=production
FLASK_APP=main_app.py
```

#### MongoDB Settings
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority
```

### 3. Runtime Configuration

Set in Azure App Service Configuration:
- **Runtime Stack**: Python 3.11
- **Startup Command**: `gunicorn --bind=0.0.0.0 --timeout=600 wsgi:application`

## 🔐 GitHub Secrets Setup

Add these secrets to your GitHub repository:

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:

### Required Secrets
- `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING`: Publish profile for staging environment
- `AZURE_WEBAPP_PUBLISH_PROFILE`: Publish profile for production environment

### How to Get Publish Profiles
1. Go to Azure Portal
2. Navigate to your App Service
3. Go to "Get publish profile"
4. Download the file
5. Copy the content and paste it as a GitHub secret

## 🚀 Deployment Process

### Automatic Deployment (Recommended)
1. Push changes to the `main` branch
2. GitHub Actions will automatically:
   - Run security scans
   - Run tests
   - Deploy to staging
   - Deploy to production (after staging success)
   - Run health checks

### Manual Deployment (For Testing)
```bash
# Set environment variables
export AZURE_WEBAPP_NAME="taskflow-staging"
export AZURE_WEBAPP_PUBLISH_PROFILE="your-publish-profile-content"

# Run deployment script
./scripts/deploy-azure.sh
```

## 🧪 Testing

### Health Check
After deployment, test the health endpoint:
```bash
curl https://taskflow-staging.azurewebsites.net/health
```

Expected response:
```json
{"status": "healthy", "message": "TaskFlow is running!"}
```

### Local Testing
Run the deployment test locally:
```bash
python test_deployment.py
```

## 🔍 Troubleshooting

### Common Issues

1. **Port Configuration**
   - Ensure `WEBSITES_PORT=8000` is set in Azure App Service Configuration

2. **Startup Command**
   - Verify the startup command is correctly set in Azure App Service

3. **Environment Variables**
   - Check that all required environment variables are configured in Azure

4. **MongoDB Connection**
   - Ensure MongoDB Atlas connection string is correct
   - Check IP whitelisting in MongoDB Atlas

5. **GitHub Secrets**
   - Verify publish profiles are correctly set in GitHub secrets
   - Check that secret names match the workflow file

### Logs
Check Azure App Service logs:
1. Go to Azure Portal
2. Navigate to your App Service
3. Go to "Log stream" or "Logs"
4. Monitor for deployment or runtime errors

## 📊 Monitoring

### Health Monitoring
- The application includes a `/health` endpoint
- GitHub Actions runs health checks after deployment
- Monitor the health endpoint for application status

### Performance Monitoring
For production, consider:
- Azure Application Insights
- Custom logging
- Performance monitoring
- Error tracking

## 🔒 Security

### Environment Variables
- Never commit sensitive information to version control
- Use Azure Key Vault for production secrets
- Rotate secrets regularly

### Database Security
- Use MongoDB Atlas IP whitelisting
- Enable MongoDB Atlas security features
- Use strong passwords and connection strings

### HTTPS
- Azure App Service provides HTTPS by default
- Configure custom domains with SSL certificates

## ✅ Verification Steps

After configuration, verify:

1. **GitHub Secrets**: All required secrets are set
2. **Azure App Service**: Environment variables are configured
3. **Runtime**: Python 3.11 and startup command are set
4. **Database**: MongoDB connection is working
5. **Deployment**: Push to main branch triggers deployment
6. **Health Check**: `/health` endpoint returns 200 OK
7. **Application**: Full application functionality works

## 🆘 Support

If you encounter issues:

1. Check Azure App Service logs
2. Verify GitHub Actions workflow runs
3. Test health endpoint manually
4. Review environment variable configuration
5. Check MongoDB Atlas connection
6. Run local deployment test

The deployment configuration is now ready for Azure App Service deployment! 