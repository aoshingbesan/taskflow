#!/bin/bash

# TaskFlow Deployment Script
# This script builds the Docker image, pushes it to ECR, and updates the ECS service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="taskflow"
AWS_REGION="us-east-1"
ECR_REPO="${PROJECT_NAME}-app"
ECS_CLUSTER="${PROJECT_NAME}-cluster"
ECS_SERVICE="${PROJECT_NAME}-service"

echo -e "${GREEN}🚀 Starting TaskFlow deployment...${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is authenticated with AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Checking AWS resources...${NC}"

# Get ECR repository URI
ECR_REPO_URI=$(aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text 2>/dev/null || echo "")

if [ -z "$ECR_REPO_URI" ]; then
    echo -e "${RED}❌ ECR repository '${ECR_REPO}' not found. Please run 'terraform apply' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found ECR repository: ${ECR_REPO_URI}${NC}"

# Get ECS cluster ARN
ECS_CLUSTER_ARN=$(aws ecs describe-clusters --clusters ${ECS_CLUSTER} --region ${AWS_REGION} --query 'clusters[0].clusterArn' --output text 2>/dev/null || echo "")

if [ -z "$ECS_CLUSTER_ARN" ]; then
    echo -e "${RED}❌ ECS cluster '${ECS_CLUSTER}' not found. Please run 'terraform apply' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found ECS cluster: ${ECS_CLUSTER_ARN}${NC}"

# Login to ECR
echo -e "${YELLOW}🔐 Logging in to ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}

# Build Docker image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker build -t ${ECR_REPO}:latest .

# Tag image for ECR
echo -e "${YELLOW}🏷️  Tagging image for ECR...${NC}"
docker tag ${ECR_REPO}:latest ${ECR_REPO_URI}:latest

# Push image to ECR
echo -e "${YELLOW}📤 Pushing image to ECR...${NC}"
docker push ${ECR_REPO_URI}:latest

# Update ECS service
echo -e "${YELLOW}🔄 Updating ECS service...${NC}"
aws ecs update-service \
    --cluster ${ECS_CLUSTER} \
    --service ${ECS_SERVICE} \
    --force-new-deployment \
    --region ${AWS_REGION}

echo -e "${GREEN}✅ Deployment initiated successfully!${NC}"
echo -e "${YELLOW}⏳ Waiting for service to stabilize...${NC}"

# Wait for service to stabilize
aws ecs wait services-stable \
    --cluster ${ECS_CLUSTER} \
    --services ${ECS_SERVICE} \
    --region ${AWS_REGION}

echo -e "${GREEN}✅ Service is stable!${NC}"

# Get the ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers --region ${AWS_REGION} --query "LoadBalancers[?contains(LoadBalancerName, '${PROJECT_NAME}')].DNSName" --output text)

if [ ! -z "$ALB_DNS" ]; then
    echo -e "${GREEN}🌐 Your application is available at: http://${ALB_DNS}${NC}"
else
    echo -e "${YELLOW}⚠️  Could not retrieve ALB DNS name. Check AWS Console for the URL.${NC}"
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}" 