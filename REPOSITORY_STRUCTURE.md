# TaskFlow Repository Structure

## 📁 Project Overview
TaskFlow is a Flask-based task management web application deployed on Azure App Service with MongoDB Atlas database.

## 🏗️ Repository Structure

```
taskflow/
├── 📁 app/                          # Main Flask application
│   ├── 📁 routes/                   # Flask route handlers
│   │   ├── auth.py                  # Authentication routes
│   │   ├── main.py                  # Main application routes
│   │   ├── tasks.py                 # Task management routes
│   │   ├── api.py                   # REST API routes
│   │   └── swagger_api.py          # API documentation
│   ├── 📁 templates/               # HTML templates
│   │   ├── 📁 auth/               # Authentication templates
│   │   ├── 📁 main/               # Main page templates
│   │   └── 📁 tasks/              # Task management templates
│   ├── __init__.py                 # Flask app factory
│   ├── models.py                   # Database models
│   ├── security.py                 # Security utilities
│   ├── monitoring.py               # Monitoring utilities
│   └── dashboard_monitoring.py     # Dashboard monitoring
├── 📁 scripts/                     # Deployment and utility scripts
│   ├── cleanup-repo.sh            # Repository cleanup script
│   ├── deploy-azure.sh            # Azure deployment script
│   ├── deploy-staging.sh          # Staging deployment script
│   ├── deploy.sh                   # General deployment script
│   ├── fix-azure-deployment.sh    # Azure deployment fixes
│   ├── monitor-deployment.sh      # Deployment monitoring
│   ├── setup-azure.sh             # Azure setup script
│   ├── setup-github-secrets.sh    # GitHub secrets setup
│   ├── setup-infrastructure.sh    # Infrastructure setup
│   ├── setup-mongodb.sh           # MongoDB setup
│   ├── setup-monitoring.sh        # Monitoring setup
│   ├── test-setup.sh              # Test environment setup
│   └── verify-deployment.sh       # Deployment verification
├── 📁 terraform/                   # Infrastructure as Code
│   ├── main.tf                    # Main Terraform configuration
│   ├── variables.tf               # Terraform variables
│   ├── terraform.tfvars           # Terraform variable values
│   └── terraform.tfvars.example  # Example variable file
├── 📁 tests/                      # Test suite
│   └── 📁 unit/                  # Unit tests
│       ├── test_basic.py         # Basic functionality tests
│       └── test_models.py        # Model tests
├── 📁 migrations/                 # Database migrations
│   ├── env.py                    # Migration environment
│   └── 📁 versions/             # Migration files
├── 📁 images/                    # Documentation images
├── 📁 .github/                   # GitHub Actions CI/CD
│   └── 📁 workflows/            # CI/CD workflows
├── 📄 main_app.py               # Main application entry point
├── 📄 app.py                    # Azure-compatible entry point
├── 📄 wsgi.py                   # WSGI entry point
├── 📄 config.py                 # Application configuration
├── 📄 requirements.txt          # Python dependencies
├── 📄 pyproject.toml           # Project configuration
├── 📄 pytest.ini               # Pytest configuration
├── 📄 Dockerfile               # Docker container definition
├── 📄 docker-compose.yml       # Docker Compose configuration
├── 📄 web.config               # Azure web.config
├── 📄 startup.sh               # Azure startup script
├── 📄 .deployment              # Azure deployment configuration
├── 📄 .dockerignore            # Docker ignore file
├── 📄 .env                     # Environment variables
├── 📄 env.example              # Environment variables example
├── 📄 azure-env.example        # Azure environment example
├── 📄 .flake8                  # Flake8 linting configuration
├── 📄 .gitignore               # Git ignore rules
├── 📄 README.md                # Project documentation
├── 📄 CHANGELOG.md             # Project changelog
├── 📄 phase.md                 # Project phase documentation
└── 📄 REPOSITORY_STRUCTURE.md  # This file

```

## 🎯 Key Components

### 🚀 **Application Core**
- **Flask Application**: Modern web framework with blueprints
- **MongoDB Integration**: NoSQL database with MongoEngine ODM
- **Authentication**: User registration, login, and session management
- **Task Management**: CRUD operations for tasks with user association

### 🛠️ **Development Tools**
- **Testing**: Pytest with unit tests and Flask test client
- **Code Quality**: Black formatting, Flake8 linting
- **CI/CD**: GitHub Actions for automated testing and deployment
- **Documentation**: Comprehensive README and API documentation

### ☁️ **Deployment & Infrastructure**
- **Azure App Service**: Production and staging environments
- **MongoDB Atlas**: Cloud database service
- **Docker Support**: Containerization for consistent deployment
- **Terraform**: Infrastructure as Code (optional)

### 📊 **Monitoring & Health**
- **Health Endpoints**: Application and database health checks
- **Logging**: Comprehensive application logging
- **Monitoring**: Resource usage and performance metrics

## 🔧 **Configuration Files**

### **Application Configuration**
- `config.py` - Flask application configuration
- `requirements.txt` - Python dependencies
- `pyproject.toml` - Project metadata and tools

### **Deployment Configuration**
- `web.config` - Azure App Service configuration
- `startup.sh` - Azure startup commands
- `Dockerfile` - Docker container definition
- `docker-compose.yml` - Local development setup

### **Development Tools**
- `.flake8` - Code linting rules
- `pytest.ini` - Testing configuration
- `.gitignore` - Version control exclusions

## 🚀 **Deployment Environments**

### **Staging Environment**
- URL: `https://taskflow-staging-new.azurewebsites.net`
- Purpose: Testing and validation
- Auto-deployment from `main` branch

### **Production Environment**
- URL: `https://taskflow-app-new.azurewebsites.net`
- Purpose: Live application
- Manual deployment from `main` branch

## 📋 **Repository Cleanup Status**

✅ **Cleaned Files:**
- Python cache files (`*.pyc`, `__pycache__`)
- Virtual environment (`venv/`)
- OS generated files (`.DS_Store`, `Thumbs.db`)
- Temporary files (`*.tmp`, `*.temp`, `*.bak`, `*.log`)
- IDE files (`.vscode/`, `.idea/`, `*.iml`)
- Terraform state files (`*.tfstate*`)
- Azure deployment files (`*.publishsettings`, `*.pubxml`)
- Recovery documentation (`RECOVERY_*.md`, `startup.txt`)
- Test coverage files (`htmlcov/`, `.coverage`)
- Database files (`*.db`, `*.sqlite*`)
- Backup files (`*.backup`, `*.old`, `*.orig`)

✅ **Kept Essential Files:**
- Application source code
- Configuration files
- Documentation
- Deployment scripts
- Test suite
- Infrastructure as Code (Terraform)

## 🎉 **Ready for Submission**

The repository is now clean and contains only the essential files needed for:
- ✅ **Application functionality**
- ✅ **Deployment and infrastructure**
- ✅ **Testing and quality assurance**
- ✅ **Documentation and project management**

**Total Repository Size**: Optimized for efficient cloning and deployment
**File Count**: Reduced to essential components only
**Git History**: Clean and professional 