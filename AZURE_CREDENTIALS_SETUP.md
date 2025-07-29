# 🔐 Azure Credentials Setup - JSON Approach

## **Updated Approach: Use JSON Credentials**

The Azure login action works better with a single JSON credentials secret.

### **Step 1: Add AZURE_CREDENTIALS Secret**

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

#### **Secret: AZURE_CREDENTIALS**
**Name:** `AZURE_CREDENTIALS`
**Value:** *(Use the JSON format with your actual credentials)*
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

### **Step 2: Remove Individual Secrets (Optional)**

You can remove the individual secrets if you want:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

### **Why This Approach?**

- ✅ Works better with Azure login action
- ✅ Avoids OIDC authentication issues
- ✅ Uses service principal authentication directly
- ✅ More reliable in CI/CD environments

**Add the AZURE_CREDENTIALS secret with the JSON format above!** 🚀 