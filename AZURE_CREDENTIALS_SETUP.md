# 🔐 Azure Credentials Setup - JSON Approach

## **Updated Approach: Use JSON Credentials**

The Azure login action works better with a single JSON credentials secret.

### **Step 1: Add AZURE_CREDENTIALS Secret**

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

#### **Secret: AZURE_CREDENTIALS**
**Name:** `AZURE_CREDENTIALS`
**Value:**
```json
{
  "clientId": "6e121fd7-9319-423d-b82d-839e9edc60d2",
  "clientSecret": "I6w8Q~sje2ZT0fL9ldGtNtP6hIKnic-36LxJubF~",
  "subscriptionId": "55862e95-58fc-4f2c-99a5-1c70e635080c",
  "tenantId": "7807bad4-75db-4549-bdcd-071a067191e2"
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