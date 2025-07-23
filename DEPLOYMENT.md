# TaskFlow Deployment Guide

This guide walks you through the complete deployment process for TaskFlow, from local development to cloud deployment.

## Prerequisites

Before starting the deployment process, ensure you have the following installed:

- **Docker Desktop**: For containerization
- **AWS CLI**: For AWS service interaction
- **Terraform**: For infrastructure as code
- **Git**: For version control

## Phase 1: Local Development with Docker

### 1.1 Test Local Docker Setup

```bash
# Build and run with Docker Compose
docker-compose up --build

# Access the application
# Open http://localhost:8000 in your browser
```

### 1.2 Verify Application Functionality

- Register a new user account
- Create and manage tasks
- Test all CRUD operations
- Verify responsive design

## Phase 2: Infrastructure Setup

### 2.1 AWS Account Setup

1. **Create AWS Account** (if you don't have one)
   - Sign up at https://aws.amazon.com
   - Set up billing alerts to avoid unexpected charges

2. **Configure AWS CLI**
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your default region (e.g., us-east-1)
   ```

3. **Verify AWS Access**
   ```bash
   aws sts get-caller-identity
   ```

### 2.2 Infrastructure Deployment

1. **Set up Terraform Variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values:
   # - db_password: A secure database password
   # - secret_key: A secure Flask secret key
   ```

2. **Deploy Infrastructure**
   ```bash
   ./scripts/setup-infrastructure.sh
   ```

3. **Verify Infrastructure**
   - Check AWS Console for created resources
   - Note the ECR repository URL and ALB DNS name

## Phase 3: Application Deployment

### 3.1 Build and Push Docker Image

1. **Deploy Application**
   ```bash
   ./scripts/deploy.sh
   ```

2. **Verify Deployment**
   - Check ECS service status in AWS Console
   - Wait for service to become stable
   - Access the application via the ALB DNS name

### 3.2 Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
# Get ECR repository URL
ECR_REPO_URI=$(aws ecr describe-repositories --repository-names taskflow-app --region us-east-1 --query 'repositories[0].repositoryUri' --output text)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO_URI

# Build and tag image
docker build -t taskflow-app .
docker tag taskflow-app:latest $ECR_REPO_URI:latest

# Push to ECR
docker push $ECR_REPO_URI:latest

# Update ECS service
aws ecs update-service \
  --cluster taskflow-cluster \
  --service taskflow-service \
  --force-new-deployment \
  --region us-east-1
```

## Phase 4: Verification and Testing

### 4.1 Application Testing

1. **Health Check**
   ```bash
   # Test health endpoint
   curl http://your-alb-dns-name/health
   ```

2. **Functional Testing**
   - Register a new user
   - Create, edit, and delete tasks
   - Test all application features

3. **Performance Testing**
   - Test application responsiveness
   - Verify database connectivity
   - Check logs in CloudWatch

### 4.2 Infrastructure Verification

1. **AWS Console Checks**
   - ECS: Verify service is running
   - RDS: Check database connectivity
   - ALB: Verify target group health
   - CloudWatch: Check application logs

2. **Cost Monitoring**
   - Set up billing alerts
   - Monitor resource usage
   - Optimize if necessary

## Troubleshooting

### Common Issues

1. **Docker Build Failures**
   ```bash
   # Clean Docker cache
   docker system prune -a
   # Rebuild
   docker build --no-cache -t taskflow .
   ```

2. **ECR Authentication Issues**
   ```bash
   # Re-authenticate with ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO_URI
   ```

3. **ECS Service Issues**
   ```bash
   # Check service events
   aws ecs describe-services --cluster taskflow-cluster --services taskflow-service --region us-east-1
   ```

4. **Database Connection Issues**
   - Verify security group rules
   - Check RDS endpoint and credentials
   - Ensure VPC configuration is correct

### Debugging Commands

```bash
# Check ECS task logs
aws logs describe-log-groups --region us-east-1

# Get ECS task details
aws ecs describe-tasks --cluster taskflow-cluster --region us-east-1

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn your-target-group-arn --region us-east-1
```

## Cost Optimization

### Estimated Monthly Costs

- **RDS t3.micro**: ~$15/month
- **ECS Fargate**: ~$10-20/month (depending on usage)
- **ALB**: ~$20/month
- **Data Transfer**: ~$5-10/month
- **Total**: ~$50-65/month

### Cost Reduction Tips

1. **Use Spot Instances** (if applicable)
2. **Right-size resources** based on actual usage
3. **Set up billing alerts**
4. **Consider reserved instances** for long-term use

## Security Considerations

### Best Practices Implemented

1. **Network Security**
   - VPC with public/private subnets
   - Security groups with minimal access
   - RDS in private subnets

2. **Application Security**
   - Non-root user in containers
   - Environment variable management
   - Secure credential handling

3. **Data Security**
   - RDS encryption at rest
   - Secure database passwords
   - HTTPS (recommended for production)

## Next Steps

### Recommended Improvements

1. **CI/CD Pipeline**
   - GitHub Actions for automated deployment
   - Automated testing and quality gates

2. **Monitoring and Alerting**
   - CloudWatch dashboards
   - Application performance monitoring
   - Error tracking and alerting

3. **Security Enhancements**
   - SSL/TLS certificates
   - WAF (Web Application Firewall)
   - Enhanced IAM policies

4. **Scalability**
   - Auto-scaling policies
   - Load balancing optimization
   - Database read replicas

## Support and Resources

- **AWS Documentation**: https://docs.aws.amazon.com/
- **Terraform Documentation**: https://www.terraform.io/docs
- **Docker Documentation**: https://docs.docker.com/
- **Flask Documentation**: https://flask.palletsprojects.com/

## Project Repository

- **GitHub**: [Your repository URL]
- **Issues**: Report bugs and feature requests
- **Wiki**: Additional documentation and guides

---

**Note**: This deployment guide assumes you have the necessary AWS permissions and understanding of cloud infrastructure. Always review security configurations and costs before deploying to production. 