#!/bin/bash

# GitHub Secrets Setup Script for TaskFlow
# This script helps you add the required secrets to GitHub

set -e

echo "🔐 Setting up GitHub Secrets for TaskFlow..."

echo ""
echo "📋 Follow these steps to add GitHub secrets:"
echo ""
echo "1. Go to your GitHub repository: https://github.com/aoshingbesan/taskflow"
echo "2. Navigate to Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret' for each secret below"
echo ""

echo "🔑 Secret 1: AZURE_CREDENTIALS"
echo "Name: AZURE_CREDENTIALS"
echo "Value:"
cat << 'EOF'
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
EOF

echo ""
echo "🔑 Secret 2: AZURE_WEBAPP_PUBLISH_PROFILE_STAGING"
echo "Name: AZURE_WEBAPP_PUBLISH_PROFILE_STAGING"
echo "Value:"
cat << 'EOF'
<publishData><publishProfile profileName="taskflow-staging - Web Deploy" publishMethod="MSDeploy" publishUrl="taskflow-staging.scm.azurewebsites.net:443" msdeploySite="taskflow-staging" userName="$taskflow-staging" userPWD="Q5ggHzN3yfsimljBpuKZnodEAGX7MmZyqxL06qog7mpHb6wXgh1lkXQysdtq" destinationAppUrl="http://taskflow-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-staging - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-blu-125.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="taskflow-staging\$taskflow-staging" userPWD="Q5ggHzN3yfsimljBpuKZnodEAGX7MmZyqxL06qog7mpHb6wXgh1lkXQysdtq" destinationAppUrl="http://taskflow-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-staging - Zip Deploy" publishMethod="ZipDeploy" publishUrl="taskflow-staging.scm.azurewebsites.net:443" userName="$taskflow-staging" userPWD="Q5ggHzN3yfsimljBpuKZnodEAGX7MmZyqxL06qog7mpHb6wXgh1lkXQysdtq" destinationAppUrl="http://taskflow-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-staging - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-blu-125dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="taskflow-staging\$taskflow-staging" userPWD="Q5ggHzN3yfsimljBpuKZnodEAGX7MmZyqxL06qog7mpHb6wXgh1lkXQysdtq" destinationAppUrl="http://taskflow-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>
EOF

echo ""
echo "🔑 Secret 3: AZURE_WEBAPP_PUBLISH_PROFILE"
echo "Name: AZURE_WEBAPP_PUBLISH_PROFILE"
echo "Value:"
cat << 'EOF'
<publishData><publishProfile profileName="taskflow-app - Web Deploy" publishMethod="MSDeploy" publishUrl="taskflow-app.scm.azurewebsites.net:443" msdeploySite="taskflow-app" userName="$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-app - FTP" publishMethod="FTP" publishUrl="ftp://waws-prod-blu-125.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="taskflow-app\$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-app - Zip Deploy" publishMethod="ZipDeploy" publishUrl="taskflow-app.scm.azurewebsites.net:443" userName="$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="taskflow-app - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftp://waws-prod-blu-125dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="taskflow-app\$taskflow-app" userPWD="j2qi03Xb8maByZ596b0W5A0krt5aibr5krN1BH0MeMa5tHleEvme9Nwh5Xmt" destinationAppUrl="http://taskflow-app.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>
EOF

echo ""
echo "✅ After adding all secrets, test the deployment:"
echo ""
echo "1. Go to GitHub Actions tab to see the workflow run"
echo "2. Check staging: https://taskflow-staging.azurewebsites.net/health"
echo "3. Check production: https://taskflow-app.azurewebsites.net/health"
echo ""
echo "🚀 Ready to deploy!" 