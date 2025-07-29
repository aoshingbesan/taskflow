# GitHub Secrets Setup Guide

## ✅ **Azure Infrastructure is Ready!**

Your Azure resources have been created successfully:
- **Staging:** `https://taskflow-staging.azurewebsites.net`
- **Production:** `https://taskflow-app.azurewebsites.net`

## 🔐 **Add These Secrets to GitHub**

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### **1. AZURE_CREDENTIALS**
**Name:** `AZURE_CREDENTIALS`
**Value:** (Copy the entire JSON below)
```json
{
  "clientId": "6e121fd7-9319-423d-b82d-839e9edc60d2",
  "clientSecret": "DDr8Q~EF7h.O4t_elbP7RXxglCe2.3C_yZIFGaU7",
  "subscriptionId": "55862e95-58fc-4f2c-99a5-1c70e635080c",
  "tenantId": "7807bad4-75db-4549-bdcd-071a067191e2",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### **2. AZURE_WEBAPP_PUBLISH_PROFILE_STAGING**
**Name:** `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING`
**Value:** (Copy the entire JSON below)
```json
{
  "SQLServerDBConnectionString": "",
  "controlPanelLink": "https://portal.azure.com",
  "databases": null,
  "destinationAppUrl": "http://taskflow-staging.azurewebsites.net",
  "hostingProviderForumLink": "",
  "msdeploySite": "taskflow-staging",
  "profileName": "taskflow-staging - Web Deploy",
  "publishMethod": "MSDeploy",
  "publishUrl": "taskflow-staging.scm.azurewebsites.net:443",
  "userName": "$taskflow-staging",
  "userPWD": "Q5ggHzN3yfsimljBpuKZnodEAGX7MmZyqxL06qog7mpHb6wXgh1lkXQysdtq",
  "webSystem": "WebSites"
}
```

### **3. AZURE_WEBAPP_PUBLISH_PROFILE**
**Name:** `AZURE_WEBAPP_PUBLISH_PROFILE`
**Value:** (Copy the entire XML below)
```xml
<publishData><publishProfile profileName="taskflow-app - Web Deploy" publishMethod="MSDeploy" publishUrl="taskflow-app.scm.azurewebsites.net:443" msdeploySite="taskflow-app" userName="$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-app - FTP" publishMethod="FTP" publishUrl="ftp://waws-prod-blu-125.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="taskflow-app\$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-app - Zip Deploy" publishMethod="ZipDeploy" publishUrl="taskflow-app.scm.azurewebsites.net:443" userName="$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-app - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftp://waws-prod-blu-125dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="taskflow-app\$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>
```

## 🚀 **Next Steps After Adding Secrets**

### **Step 1: Test Staging Deployment**
```bash
# Create develop branch if it doesn't exist
git checkout -b develop
git push origin develop

# Make a test change
echo "# Test deployment" >> README.md
git add README.md
git commit -m "Test staging deployment"
git push origin develop
```

### **Step 2: Check Deployment**
1. Go to GitHub Actions tab
2. Watch the `staging-deploy.yml` workflow
3. Visit `https://taskflow-staging.azurewebsites.net/health`

### **Step 3: Test Production Deployment**
1. Create a pull request from `develop` to `main`
2. Review and approve the PR
3. Watch the `production-deploy.yml` workflow
4. Visit `https://taskflow-app.azurewebsites.net/health`

## 📋 **Checklist**

- [ ] Add `AZURE_CREDENTIALS` secret to GitHub
- [ ] Add `AZURE_WEBAPP_PUBLISH_PROFILE_STAGING` secret to GitHub
- [ ] Add `AZURE_WEBAPP_PUBLISH_PROFILE` secret to GitHub
- [ ] Test staging deployment
- [ ] Test production deployment
- [ ] Verify health checks

## 🎯 **Expected Results**

After successful deployment, you should see:
```json
{"status": "healthy", "message": "TaskFlow is running!"}
```

When you visit:
- `https://taskflow-staging.azurewebsites.net/health`
- `https://taskflow-app.azurewebsites.net/health`

## 🔧 **Troubleshooting**

### **If deployment fails:**
1. Check GitHub Actions logs
2. Verify all secrets are correctly added
3. Ensure App Service environment variables are set
4. Check that MongoDB connection string is configured

### **If health check fails:**
1. Review Azure App Service logs
2. Verify startup command is correct
3. Check environment variables in Azure Portal

**Ready to add the secrets and test deployment!** 🚀 