# Setup Permissions and Secrets for Workflows

## 🔐 Required GitHub Secrets

### **1. Azure Credentials**
You need to create a service principal for Azure authentication:

#### **Create Azure Service Principal:**
```bash
# Login to Azure CLI
az login

# Create service principal
az ad sp create-for-rbac --name "taskflow-github-actions" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
  --sdk-auth
```

#### **Add to GitHub Secrets:**
- **Name:** `AZURE_CREDENTIALS`
- **Value:** The entire JSON output from the service principal creation

### **2. Azure App Service Publish Profiles**

#### **For Staging Environment:**
1. Go to Azure Portal → App Service `taskflow-staging`
2. Click "Get publish profile"
3. Download the `.PublishSettings` file
4. Copy the content and add as GitHub secret:
   - **Name:** `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING`
   - **Value:** Content of the publish profile file

#### **For Production Environment:**
1. Go to Azure Portal → App Service `taskflow-app`
2. Click "Get publish profile"
3. Download the `.PublishSettings` file
4. Copy the content and add as GitHub secret:
   - **Name:** `AZURE_WEBAPP_PUBLISH_PROFILE`
   - **Value:** Content of the publish profile file

### **3. Container Registry Access**
The workflows use GitHub Container Registry (GHCR) with automatic authentication:
- **Registry:** `ghcr.io`
- **Username:** `${{ github.actor }}` (your GitHub username)
- **Password:** `${{ secrets.GITHUB_TOKEN }}` (automatically provided)

## 🔧 Workflow Permissions

### **Staging Deployment Workflow**
- ✅ **Contents:** `read` - Access to repository code
- ✅ **Packages:** `write` - Push Docker images to GHCR
- ✅ **Id-token:** `write` - Azure authentication

### **Production Deployment Workflow**
- ✅ **Contents:** `read` - Access to repository code
- ✅ **Packages:** `write` - Push Docker images to GHCR
- ✅ **Id-token:** `write` - Azure authentication

### **CI Workflow**
- ✅ **Contents:** `read` - Access to repository code
- ✅ **Packages:** `write` - Push Docker images to GHCR
- ✅ **Id-token:** `write` - Azure authentication

## 🚀 How to Set Up Secrets

### **Step 1: Create Azure Service Principal**
```bash
# Login to Azure
az login

# Create service principal (replace with your subscription and resource group)
az ad sp create-for-rbac \
  --name "taskflow-github-actions" \
  --role contributor \
  --scopes /subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/YOUR-RESOURCE-GROUP \
  --sdk-auth
```

### **Step 2: Add Secrets to GitHub**
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | Output from az ad sp create-for-rbac |
| `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING` | Staging publish profile | Content of staging .PublishSettings file |
| `AZURE_WEBAPP_PUBLISH_PROFILE` | Production publish profile | Content of production .PublishSettings file |

## 🔍 Verification Steps

### **1. Test Azure Authentication**
```bash
# Test Azure login
az login --service-principal \
  --username YOUR-SP-APP-ID \
  --password YOUR-SP-PASSWORD \
  --tenant YOUR-TENANT-ID
```

### **2. Test Container Registry Access**
```bash
# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR-GITHUB-USERNAME --password-stdin

# Test push (if you have a local image)
docker tag your-image ghcr.io/YOUR-USERNAME/taskflow:test
docker push ghcr.io/YOUR-USERNAME/taskflow:test
```

### **3. Test Azure App Service Access**
```bash
# List your app services
az webapp list --resource-group YOUR-RESOURCE-GROUP --output table
```

## 🛠️ Troubleshooting

### **Common Issues:**

#### **1. "Permission denied" for Container Registry**
- Ensure `GITHUB_TOKEN` has `write:packages` permission
- Check that the workflow has `packages: write` permission

#### **2. "Authentication failed" for Azure**
- Verify `AZURE_CREDENTIALS` secret is correctly formatted
- Ensure service principal has proper roles assigned
- Check that `id-token: write` permission is set

#### **3. "Publish profile not found"**
- Verify publish profile secrets are correctly set
- Ensure the App Services exist and are accessible
- Check that the service principal has access to the App Services

#### **4. "Health check failed"**
- Verify App Service environment variables are configured
- Check that the application is properly deployed
- Review App Service logs for errors

## 📋 Environment Variables for Azure App Service

### **Staging Environment (`taskflow-staging`):**
```
WEBSITES_PORT=8000
SCM_DO_BUILD_DURING_DEPLOYMENT=true
PYTHONPATH=/home/site/wwwroot
SECRET_KEY=your-super-secret-key
FLASK_ENV=production
FLASK_APP=main_app.py
MONGODB_URI=your-mongodb-connection-string
```

### **Production Environment (`taskflow-app`):**
```
WEBSITES_PORT=8000
SCM_DO_BUILD_DURING_DEPLOYMENT=true
PYTHONPATH=/home/site/wwwroot
SECRET_KEY=your-super-secret-key
FLASK_ENV=production
FLASK_APP=main_app.py
MONGODB_URI=your-mongodb-connection-string
```

## 🔒 Security Best Practices

1. **Rotate Secrets Regularly:** Update service principal passwords and publish profiles periodically
2. **Use Least Privilege:** Only grant necessary permissions to service principals
3. **Monitor Access:** Regularly review who has access to your secrets
4. **Use Environment Secrets:** For production, consider using Azure Key Vault
5. **Audit Logs:** Monitor GitHub Actions logs for any suspicious activity

## ✅ Checklist

- [ ] Azure service principal created
- [ ] `AZURE_CREDENTIALS` secret added to GitHub
- [ ] Staging publish profile secret added
- [ ] Production publish profile secret added
- [ ] App Service environment variables configured
- [ ] Container registry access verified
- [ ] Test deployment to staging
- [ ] Test deployment to production
- [ ] Health checks passing

Once all secrets are configured, your workflows will be able to:
- ✅ Login to Azure using service principal
- ✅ Access and deploy to staging environment
- ✅ Access and deploy to production environment
- ✅ Login to GitHub Container Registry
- ✅ Push Docker images to the registry
- ✅ Pull images for deployment 