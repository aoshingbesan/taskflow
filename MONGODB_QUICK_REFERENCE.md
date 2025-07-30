# 🗄️ MongoDB Atlas Quick Reference

## 🚀 **Quick Setup Steps**

### **1. Create MongoDB Atlas Account**
- Go to: https://cloud.mongodb.com/
- Sign up or log in
- Create project: "TaskFlow"

### **2. Create Free Cluster**
- Click "Build a Database"
- Choose: **FREE** tier (M0)
- Provider: **AWS**
- Region: **East US** (close to Azure)
- Click "Create"

### **3. Configure Database Access**
- Go to: Security → Database Access
- Click "Add New Database User"
- Username: `taskflow-user`
- Password: `[generate strong password]`
- Role: "Read and write to any database"

### **4. Configure Network Access**
- Go to: Security → Network Access
- Click "Add IP Address"
- Click "Allow Access from Anywhere" (0.0.0.0/0)

### **5. Get Connection String**
- Go to your cluster
- Click "Connect"
- Choose "Connect your application"
- Copy connection string
- Replace `<password>` with actual password

### **6. Configure Azure App Service**
```bash
# Run the setup script with your connection string
./scripts/setup-mongodb.sh 'mongodb+srv://taskflow-user:YOUR_PASSWORD@cluster.mongodb.net/taskflow?retryWrites=true&w=majority'
```

## 📋 **Connection String Format**
```
mongodb+srv://taskflow-user:YOUR_PASSWORD@cluster.mongodb.net/taskflow?retryWrites=true&w=majority
```

## 🔧 **Azure Configuration Commands**
```bash
# Configure staging
az webapp config appsettings set \
  --name taskflow-staging \
  --resource-group taskflow-rg \
  --settings MONGODB_URI="YOUR_CONNECTION_STRING"

# Configure production
az webapp config appsettings set \
  --name taskflow-app \
  --resource-group taskflow-rg \
  --settings MONGODB_URI="YOUR_CONNECTION_STRING"

# Restart applications
az webapp restart --name taskflow-staging --resource-group taskflow-rg
az webapp restart --name taskflow-app --resource-group taskflow-rg
```

## 🧪 **Quick Test Commands**
```bash
# Test health
curl https://taskflow-app.azurewebsites.net/health

# Test API health
curl https://taskflow-app.azurewebsites.net/api/v1/health

# Test user registration (via web interface)
open https://taskflow-app.azurewebsites.net/register
```

## 🔍 **Troubleshooting**

### **Common Issues:**
1. **Connection Failed**: Check network access (0.0.0.0/0)
2. **Authentication Failed**: Verify username/password
3. **Permission Denied**: Check database user role
4. **Timeout**: Check connection string format

### **Verification Steps:**
1. Check MongoDB Atlas dashboard
2. Verify database user exists
3. Check network access settings
4. Test connection string locally

## 📊 **Expected Database Structure**
```
taskflow/
├── users/
│   ├── _id: ObjectId
│   ├── username: String
│   ├── email: String
│   ├── password_hash: String
│   └── created_at: Date
└── tasks/
    ├── _id: ObjectId
    ├── title: String
    ├── description: String
    ├── status: String
    ├── priority: String
    ├── due_date: Date
    ├── user_id: ObjectId
    └── created_at: Date
```

## 🎯 **Success Indicators**
- ✅ Health endpoint returns 200
- ✅ User registration works
- ✅ User login works
- ✅ Task creation works
- ✅ Data appears in MongoDB Atlas

## 📞 **Support Resources**
- MongoDB Atlas Documentation: https://docs.atlas.mongodb.com/
- Connection String Guide: https://docs.mongodb.com/guides/cloud/connectionstring/
- Network Access: https://docs.atlas.mongodb.com/security-ip-access-list/

**Ready to set up MongoDB Atlas!** 🚀 