# Azure App Service Deployment Configuration

This document provides instructions for deploying TaskFlow to Azure App Service.

## Prerequisites

1. **Azure Account**: You need an active Azure subscription
2. **Azure CLI**: Install Azure CLI for local deployment
3. **GitHub Secrets**: Configure the following secrets in your GitHub repository

## GitHub Secrets Configuration

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

- `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING`: Publish profile for staging environment
- `AZURE_WEBAPP_PUBLISH_PROFILE`: Publish profile for production environment

## Azure App Service Configuration

### 1. Create Azure App Service

Create two App Services in Azure:
- `taskflow-staging` (for staging environment)
- `taskflow-app` (for production environment)

### 2. Configure App Service Settings

For each App Service, configure these application settings:

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

Set the following in Azure App Service Configuration:

- **Runtime Stack**: Python 3.11
- **Startup Command**: `gunicorn --bind=0.0.0.0 --timeout=600 wsgi:application`

## Deployment Files

The following files are required for Azure deployment:

### `.deployment`
Configures Azure App Service deployment settings.

### `web.config`
Configures IIS for Python application hosting.

### `startup.txt`
Specifies the startup command for the application.

### `wsgi.py`
Entry point for the Flask application.

## Manual Deployment

You can deploy manually using the provided script:

```bash
# Set environment variables
export AZURE_WEBAPP_NAME="taskflow-staging"
export AZURE_WEBAPP_PUBLISH_PROFILE="your-publish-profile-content"

# Run deployment script
./scripts/deploy-azure.sh
```

## Troubleshooting

### Common Issues

1. **Port Configuration**: Ensure `WEBSITES_PORT=8000` is set in Azure App Service Configuration
2. **Startup Command**: Verify the startup command is correctly set
3. **Environment Variables**: Check that all required environment variables are configured
4. **MongoDB Connection**: Ensure MongoDB Atlas connection string is correct and accessible

### Health Check

The application includes a health check endpoint at `/health`. You can test it:

```bash
curl https://taskflow-staging.azurewebsites.net/health
```

Expected response:
```json
{"status": "healthy", "message": "TaskFlow is running!"}
```

### Logs

Check Azure App Service logs in the Azure portal:
1. Go to your App Service
2. Navigate to "Log stream" or "Logs"
3. Monitor for any deployment or runtime errors

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/cd.yml`) automatically deploys:
- Staging: On push to `main` branch
- Production: After successful staging deployment

The pipeline includes:
- Security scanning (Safety, Bandit)
- Code quality checks (Flake8, Black)
- Testing (Pytest)
- Deployment to Azure App Service
- Health checks

## Security Considerations

1. **Environment Variables**: Never commit sensitive information to version control
2. **MongoDB Atlas**: Use IP whitelisting for database access
3. **HTTPS**: Azure App Service provides HTTPS by default
4. **Secrets Management**: Use Azure Key Vault for production secrets

## Monitoring

The application includes basic health monitoring. For production, consider:
- Azure Application Insights
- Custom logging
- Performance monitoring
- Error tracking 