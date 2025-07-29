# 🔐 Update Azure Credentials in GitHub

## **IMPORTANT: Update AZURE_CREDENTIALS Secret**

The Azure service principal credentials have been refreshed. You need to update the `AZURE_CREDENTIALS` secret in your GitHub repository.

### **Steps:**

1. **Go to GitHub Repository Settings**
   - Navigate to your repository: `https://github.com/aoshingbesan/taskflow`
   - Click **Settings** tab
   - Click **Secrets and variables** → **Actions**

2. **Update AZURE_CREDENTIALS**
   - Find the existing `AZURE_CREDENTIALS` secret
   - Click **Update**
   - Replace the entire JSON value with:

```json
{
  "client-id": "6e121fd7-9319-423d-b82d-839e9edc60d2",
  "client-secret": "I6w8Q~sje2ZT0fL9ldGtNtP6hIKnic-36LxJubF~",
  "subscription-id": "55862e95-58fc-4f2c-99a5-1c70e635080c",
  "tenant-id": "7807bad4-75db-4549-bdcd-071a067191e2"
}
```

3. **Save the Changes**
   - Click **Update secret**

### **Why This Update is Needed:**

- The previous service principal credentials may have expired
- The new credentials have the correct permissions for Azure App Service deployment
- This will fix the "No credentials found" error in the GitHub Actions workflow

### **After Updating:**

1. The next deployment should work correctly
2. The Azure login step will succeed
3. The staging deployment will complete successfully

**Update the secret now to fix the deployment issue!** 🚀 