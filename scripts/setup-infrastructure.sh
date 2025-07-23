#!/bin/bash

# TaskFlow Infrastructure Setup Script
# This script sets up the AWS infrastructure using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏗️  Starting TaskFlow infrastructure setup...${NC}"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}📦 You can install Terraform from: https://www.terraform.io/downloads.html${NC}"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}📦 You can install AWS CLI from: https://aws.amazon.com/cli/${NC}"
    exit 1
fi

# Check if user is authenticated with AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Change to terraform directory
cd terraform

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found. Creating from example...${NC}"
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example terraform.tfvars
        echo -e "${YELLOW}📝 Please edit terraform.tfvars with your values before continuing.${NC}"
        echo -e "${YELLOW}🔑 You need to set db_password and secret_key variables.${NC}"
        exit 1
    else
        echo -e "${RED}❌ terraform.tfvars.example not found.${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}🔍 Initializing Terraform...${NC}"
terraform init

echo -e "${YELLOW}📋 Planning Terraform changes...${NC}"
terraform plan

echo -e "${YELLOW}⚠️  This will create AWS resources that may incur costs.${NC}"
echo -e "${YELLOW}💰 Estimated monthly cost: ~$20-30 USD${NC}"
read -p "Do you want to proceed with applying the Terraform configuration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ Setup cancelled.${NC}"
    exit 1
fi

echo -e "${YELLOW}🚀 Applying Terraform configuration...${NC}"
terraform apply -auto-approve

echo -e "${GREEN}✅ Infrastructure setup completed successfully!${NC}"

# Get outputs
echo -e "${YELLOW}📊 Infrastructure outputs:${NC}"
terraform output

echo -e "${GREEN}🎉 Your AWS infrastructure is ready!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "${YELLOW}   1. Run the deployment script: ./scripts/deploy.sh${NC}"
echo -e "${YELLOW}   2. Or manually build and push your Docker image${NC}" 