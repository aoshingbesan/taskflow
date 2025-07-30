#!/bin/bash

# MongoDB Atlas Setup Script for TaskFlow
# This script helps you set up MongoDB Atlas for your application

set -e

echo "🗄️ MongoDB Atlas Setup for TaskFlow"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}📋 Step-by-Step MongoDB Atlas Setup${NC}"
echo ""

echo -e "${YELLOW}Step 1: Create MongoDB Atlas Account${NC}"
echo "1. Go to https://cloud.mongodb.com/"
echo "2. Sign up or log in to your account"
echo "3. Create a new project called 'TaskFlow'"
echo ""

echo -e "${YELLOW}Step 2: Create a Free Cluster${NC}"
echo "1. Click 'Build a Database'"
echo "2. Choose 'FREE' tier (M0)"
echo "3. Select 'AWS' as provider"
echo "4. Choose a region close to your Azure App Service (East US)"
echo "5. Click 'Create'"
echo ""

echo -e "${YELLOW}Step 3: Configure Database Access${NC}"
echo "1. Go to Security → Database Access"
echo "2. Click 'Add New Database User'"
echo "3. Username: taskflow-user"
echo "4. Password: [generate a strong password]"
echo "5. Role: 'Read and write to any database'"
echo "6. Click 'Add User'"
echo ""

echo -e "${YELLOW}Step 4: Configure Network Access${NC}"
echo "1. Go to Security → Network Access"
echo "2. Click 'Add IP Address'"
echo "3. Click 'Allow Access from Anywhere' (0.0.0.0/0)"
echo "4. Click 'Confirm'"
echo ""

echo -e "${YELLOW}Step 5: Get Connection String${NC}"
echo "1. Go to your cluster"
echo "2. Click 'Connect'"
echo "3. Choose 'Connect your application'"
echo "4. Copy the connection string"
echo "5. Replace <password> with your actual password"
echo ""

echo -e "${GREEN}✅ After completing the above steps, run this script again with the connection string${NC}"
echo ""

# Check if connection string is provided
if [ "$1" != "" ]; then
    echo -e "${BLUE}🔧 Configuring Azure App Service with MongoDB${NC}"
    echo ""
    
    MONGODB_URI="$1"
    
    echo "Configuring staging environment..."
    az webapp config appsettings set \
        --name taskflow-staging \
        --resource-group taskflow-rg \
        --settings MONGODB_URI="$MONGODB_URI"
    
    echo "Configuring production environment..."
    az webapp config appsettings set \
        --name taskflow-app \
        --resource-group taskflow-rg \
        --settings MONGODB_URI="$MONGODB_URI"
    
    echo ""
    echo -e "${GREEN}✅ MongoDB connection string configured!${NC}"
    echo ""
    
    echo -e "${BLUE}🔄 Restarting applications...${NC}"
    echo "Restarting staging environment..."
    az webapp restart --name taskflow-staging --resource-group taskflow-rg
    
    echo "Restarting production environment..."
    az webapp restart --name taskflow-app --resource-group taskflow-rg
    
    echo ""
    echo -e "${GREEN}✅ Applications restarted!${NC}"
    echo ""
    
    echo -e "${BLUE}🧪 Testing MongoDB Connection${NC}"
    echo "Waiting 30 seconds for applications to restart..."
    sleep 30
    
    echo "Testing staging environment..."
    STAGING_RESPONSE=$(curl -s https://taskflow-staging.azurewebsites.net/health)
    echo "Staging response: $STAGING_RESPONSE"
    
    echo "Testing production environment..."
    PROD_RESPONSE=$(curl -s https://taskflow-app.azurewebsites.net/health)
    echo "Production response: $PROD_RESPONSE"
    
    echo ""
    echo -e "${GREEN}✅ MongoDB Atlas setup complete!${NC}"
    echo ""
    echo -e "${BLUE}🎯 Next Steps:${NC}"
    echo "1. Test user registration: https://taskflow-app.azurewebsites.net/register"
    echo "2. Test user login: https://taskflow-app.azurewebsites.net/login"
    echo "3. Create and manage tasks through the web interface"
    echo "4. Check the API documentation: https://taskflow-app.azurewebsites.net/docs"
    
else
    echo -e "${YELLOW}📝 Usage:${NC}"
    echo "After setting up MongoDB Atlas, run:"
    echo "./scripts/setup-mongodb.sh 'mongodb+srv://taskflow-user:YOUR_PASSWORD@cluster.mongodb.net/taskflow?retryWrites=true&w=majority'"
    echo ""
    echo -e "${BLUE}💡 Tips:${NC}"
    echo "- Use a strong password for the database user"
    echo "- Keep your connection string secure"
    echo "- Consider using separate databases for staging and production"
    echo "- Enable MongoDB Atlas monitoring for better insights"
fi

echo ""
echo -e "${GREEN}🚀 Ready to set up MongoDB Atlas!${NC}" 