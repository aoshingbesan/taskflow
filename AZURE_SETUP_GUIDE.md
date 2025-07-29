# 🔐 Azure Setup Guide

## **Add AZURE_CREDENTIALS Secret**

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### **Secret: AZURE_CREDENTIALS**
**Name:** `AZURE_CREDENTIALS`
**Value:** *(Use your actual Azure service principal credentials)*
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret", 
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

### **How to Get These Values:**

1. **Run this command locally:**
   ```bash
   az ad sp create-for-rbac --name "taskflow-github-actions" --role contributor --scopes /subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/taskflow-rg --sdk-auth
   ```

2. **Copy the JSON output** and use it as the secret value

3. **Replace the placeholder values** with your actual credentials

**This should resolve the Azure authentication issues!** 🚀 