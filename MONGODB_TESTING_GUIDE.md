# 🧪 MongoDB Testing Guide for TaskFlow

## ✅ **After MongoDB Atlas Setup**

Once you've completed the MongoDB Atlas setup and configured the connection string, use this guide to test the full functionality.

## 📋 **Testing Checklist**

### **1. Health Check Verification**
```bash
# Test basic health
curl https://taskflow-app.azurewebsites.net/health

# Test API health
curl https://taskflow-app.azurewebsites.net/api/v1/health
```

**Expected Response:**
```json
{"message":"TaskFlow is running!","status":"healthy"}
{"service":"taskflow-api","status":"healthy","version":"1.0.0"}
```

### **2. User Registration Test**

**URL:** https://taskflow-app.azurewebsites.net/register

**Test Data:**
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "TestPassword123!"
}
```

**Expected Result:**
- User account created successfully
- Redirected to login page
- User appears in MongoDB database

### **3. User Login Test**

**URL:** https://taskflow-app.azurewebsites.net/login

**Test Data:**
```json
{
  "username": "testuser",
  "password": "TestPassword123!"
}
```

**Expected Result:**
- Login successful
- Redirected to dashboard
- Session created

### **4. Task Management Tests**

#### **Create Task**
**URL:** https://taskflow-app.azurewebsites.net/tasks/create

**Test Data:**
```json
{
  "title": "Test Task",
  "description": "This is a test task",
  "priority": "medium",
  "due_date": "2024-12-31"
}
```

#### **List Tasks**
**URL:** https://taskflow-app.azurewebsites.net/tasks

**Expected Result:**
- Task list displayed
- Created task appears in list

#### **Update Task**
**URL:** https://taskflow-app.azurewebsites.net/tasks/{task_id}/edit

**Test Data:**
```json
{
  "title": "Updated Test Task",
  "description": "This task has been updated",
  "status": "in_progress"
}
```

#### **Delete Task**
**URL:** https://taskflow-app.azurewebsites.net/tasks/{task_id}/delete

**Expected Result:**
- Task removed from database
- Redirected to task list

### **5. API Endpoint Tests**

#### **User Registration API**
```bash
curl -X POST https://taskflow-app.azurewebsites.net/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "apitestuser",
    "email": "apitest@example.com",
    "password": "ApiTest123!"
  }'
```

#### **User Login API**
```bash
curl -X POST https://taskflow-app.azurewebsites.net/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "apitestuser",
    "password": "ApiTest123!"
  }'
```

#### **Create Task API**
```bash
curl -X POST https://taskflow-app.azurewebsites.net/api/v1/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "API Test Task",
    "description": "Created via API",
    "priority": "high",
    "due_date": "2024-12-31"
  }'
```

#### **List Tasks API**
```bash
curl -X GET https://taskflow-app.azurewebsites.net/api/v1/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### **6. Dashboard Verification**

**URL:** https://taskflow-app.azurewebsites.net/dashboard

**Expected Elements:**
- Total tasks count
- Tasks by status (pending, in progress, completed)
- Recent tasks list
- User information

### **7. Database Verification**

#### **Check MongoDB Atlas Dashboard**
1. Go to MongoDB Atlas dashboard
2. Navigate to your cluster
3. Click "Browse Collections"
4. Verify databases and collections:
   - `taskflow` database
   - `users` collection
   - `tasks` collection

#### **Expected Collections:**
```javascript
// users collection
{
  "_id": ObjectId("..."),
  "username": "testuser",
  "email": "test@example.com",
  "password_hash": "...",
  "created_at": ISODate("..."),
  "updated_at": ISODate("...")
}

// tasks collection
{
  "_id": ObjectId("..."),
  "title": "Test Task",
  "description": "This is a test task",
  "status": "pending",
  "priority": "medium",
  "due_date": ISODate("2024-12-31"),
  "user_id": ObjectId("..."),
  "created_at": ISODate("..."),
  "updated_at": ISODate("...")
}
```

## 🔍 **Troubleshooting**

### **If User Registration Fails:**
1. Check MongoDB connection string
2. Verify database user permissions
3. Check application logs for errors
4. Ensure network access is configured

### **If Login Fails:**
1. Verify user exists in database
2. Check password hashing
3. Verify session management
4. Check authentication middleware

### **If Task Operations Fail:**
1. Verify user authentication
2. Check task model validation
3. Verify database permissions
4. Check API endpoint configuration

### **If API Calls Fail:**
1. Check authentication headers
2. Verify JSON payload format
3. Check CORS configuration
4. Verify API route definitions

## 📊 **Performance Testing**

### **Load Testing**
```bash
# Test multiple concurrent users
for i in {1..10}; do
  curl -s https://taskflow-app.azurewebsites.net/health &
done
wait
```

### **Database Performance**
- Monitor MongoDB Atlas metrics
- Check query performance
- Verify index usage
- Monitor connection pool

## 🎯 **Success Criteria**

Your MongoDB setup is complete when:
- ✅ User registration works
- ✅ User login works
- ✅ Task CRUD operations work
- ✅ API endpoints respond correctly
- ✅ Data persists in MongoDB Atlas
- ✅ Dashboard displays correct statistics

## 🚀 **Next Steps After Testing**

1. **Production Data Migration**: Set up data migration scripts
2. **Backup Strategy**: Configure MongoDB Atlas backups
3. **Monitoring**: Set up alerts for database performance
4. **Security**: Implement additional security measures
5. **Scaling**: Plan for database scaling as needed

**Ready to test your MongoDB functionality!** 🎉 