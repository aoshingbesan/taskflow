# 🗄️ MongoDB Atlas Setup Guide

## **Step 1: Create MongoDB Atlas Cluster**

1. **Go to [MongoDB Atlas](https://cloud.mongodb.com/)**
2. **Sign up/Login** with your account
3. **Create a new project** (e.g., "TaskFlow")
4. **Build a new cluster:**
   - Choose **FREE** tier (M0)
   - Select **AWS** as provider
   - Choose a **region** close to your Azure App Service
   - Click **Create**

## **Step 2: Configure Database Access**

1. **Go to Security → Database Access**
2. **Add New Database User:**
   - Username: `taskflow-user`
   - Password: `[generate a strong password]`
   - Role: `Read and write to any database`
   - Click **Add User**

## **Step 3: Configure Network Access**

1. **Go to Security → Network Access**
2. **Add IP Address:**
   - Click **Add IP Address**
   - Click **Allow Access from Anywhere** (0.0.0.0/0)
   - Click **Confirm**

## **Step 4: Get Connection String**

1. **Go to your cluster**
2. **Click "Connect"**
3. **Choose "Connect your application"**
4. **Copy the connection string**
5. **Replace `<password>` with your actual password**

## **Step 5: Configure Azure App Service**

### **For Staging Environment:**

```bash
az webapp config appsettings set --name taskflow-staging --resource-group taskflow-rg --settings MONGODB_URI="mongodb+srv://taskflow-user:YOUR_PASSWORD@cluster.mongodb.net/taskflow-staging?retryWrites=true&w=majority"
```

### **For Production Environment:**

```bash
az webapp config appsettings set --name taskflow-app --resource-group taskflow-rg --settings MONGODB_URI="mongodb+srv://taskflow-user:YOUR_PASSWORD@cluster.mongodb.net/taskflow-prod?retryWrites=true&w=majority"
```

## **Step 6: Test the Connection**

After setting the environment variables, restart the apps:

```bash
# Restart staging
az webapp restart --name taskflow-staging --resource-group taskflow-rg

# Restart production  
az webapp restart --name taskflow-app --resource-group taskflow-rg
```

## **Step 7: Verify Connection**

Check the logs to see if MongoDB connected successfully:

```bash
# Check staging logs
az webapp log tail --name taskflow-staging --resource-group taskflow-rg

# Check production logs
az webapp log tail --name taskflow-app --resource-group taskflow-rg
```

**Look for:** `"MongoDB connected successfully"` in the logs.

## **Security Notes:**

- ✅ Use strong passwords
- ✅ Consider IP restrictions for production
- ✅ Use separate databases for staging/production
- ✅ Enable MongoDB Atlas monitoring

**Ready to set up your MongoDB Atlas cluster?** 🚀 