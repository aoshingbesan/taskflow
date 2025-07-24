# TaskFlow - Personal Task Management

TaskFlow is a clean and simple task management web application where users can create, organize, and track their personal tasks with ease. It solves the problem of scattered to-do lists and forgotten tasks by providing a centralized, always-accessible place to manage daily responsibilities and projects.

## Features

- **User Authentication**: Secure user registration and login system
- **Task Management**: Create, edit, and delete tasks with titles and descriptions
- **Status Tracking**: Track task progress with status indicators (To Do, In Progress, Completed)
- **Dashboard**: Visual overview of task statistics and recent activities
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Filtering**: View tasks by status to focus on what matters most

## Tech Stack

- **Backend**: Python Flask
- **Frontend**: HTML/CSS/JavaScript with Bootstrap 5
- **Database**: MongoDB Atlas (Cloud Database)
- **Authentication**: Flask-Login with password hashing
- **Testing**: pytest with coverage reporting
- **CI/CD**: GitHub Actions with automated testing and linting
- **Cloud Platform**: Azure App Service
- **Infrastructure**: Terraform (Infrastructure as Code)
- **Containerization**: Docker
- **Monitoring**: Azure Application Insights

## Project Structure

```
taskflow/
├── app/                    # Flask application
│   ├── __init__.py         # Application factory
│   ├── models.py           # Database models
│   ├── routes/             # Route handlers
│   │   ├── auth.py         # Authentication routes
│   │   ├── main.py         # Main routes
│   │   ├── tasks.py        # Task management
│   │   ├── api.py          # REST API endpoints
│   │   └── swagger_api.py  # API documentation
│   ├── static/             # Static assets
│   └── templates/          # HTML templates
├── tests/                  # Test suite
│   └── unit/              # Unit tests
├── terraform/             # Infrastructure as Code
├── images/                # Screenshots for submission
├── scripts/               # Deployment scripts
├── migrations/            # Database migrations
├── .github/               # GitHub Actions workflows
├── README.md              # This documentation
├── phase.md               # Phase 2 submission details
├── requirements.txt       # Python dependencies
├── Dockerfile             # Container configuration
├── docker-compose.yml     # Docker setup
├── main_app.py            # Application entry point
├── wsgi.py                # WSGI entry point
├── config.py              # Configuration
├── env.example            # Environment variables template
├── test_simple.py         # Simple test runner
├── pytest.ini            # pytest configuration
├── .flake8                # flake8 configuration
├── pyproject.toml         # Project metadata
└── .gitignore            # Git ignore rules
```

## 🐳 Docker-Based Setup Instructions

### Prerequisites

- **Docker** installed on your system
- **Docker Compose** (usually comes with Docker Desktop)
- **Git** for cloning the repository

### Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone https://github.com/aoshingbesan/taskflow.git
   cd taskflow
   ```

2. **Set up environment variables**
   ```bash
   # Copy the example environment file
   cp env.example .env
   
   # Edit .env with your MongoDB Atlas connection string
   # Get your connection string from MongoDB Atlas dashboard
   ```

3. **Build and run with Docker Compose**
   ```bash
   # Build and start all services
   docker-compose up --build
   
   # Or run in detached mode
   docker-compose up -d --build
   ```

4. **Access the application**
   - **Main Application**: http://localhost:8000
   - **API Documentation**: http://localhost:8000/docs
   - **Health Check**: http://localhost:8000/health

5. **Stop the containers**
   ```bash
   docker-compose down
   ```

### Docker Commands Reference

#### **Building and Running**
```bash
# Build the Docker image
docker build -t taskflow .

# Run the container locally
docker run -p 8000:8000 taskflow

# Run with environment variables
docker run -p 8000:8000 \
  -e MONGODB_URI="your-mongodb-connection-string" \
  -e SECRET_KEY="your-secret-key" \
  taskflow
```

#### **Development with Docker**
```bash
# Run in development mode with volume mounting
docker run -p 8000:8000 \
  -v $(pwd):/app \
  -e FLASK_ENV=development \
  taskflow

# Run with hot reload
docker-compose -f docker-compose.dev.yml up
```

#### **Docker Compose Commands**
```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and start
docker-compose up --build

# Remove all containers and volumes
docker-compose down -v
```

### Environment Variables

Create a `.env` file in the root directory:

```env
# Flask Configuration
SECRET_KEY=your-super-secret-key-here
FLASK_ENV=production
FLASK_DEBUG=False

# MongoDB Configuration
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority

# Application Configuration
APP_NAME=TaskFlow
APP_VERSION=1.0.0
```

### Dockerfile Details

The application uses a multi-stage Docker build for optimization:

```dockerfile
# Build stage
FROM python:3.9-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

# Security: Run as non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["python", "main_app.py"]
```

### Docker Compose Configuration

The `docker-compose.yml` file sets up the complete development environment:

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=development
      - MONGODB_URI=${MONGODB_URI}
      - SECRET_KEY=${SECRET_KEY}
    volumes:
      - .:/app
    restart: unless-stopped
```

## Local Development Setup (Alternative)

### Prerequisites

- Python 3.9 or higher
- MongoDB Atlas account
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aoshingbesan/taskflow.git
   cd taskflow
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   SECRET_KEY=your-secret-key-here
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority
   ```

5. **Run the application**
   ```bash
   python main_app.py
   ```

6. **Access the application**
   Open your browser and navigate to `http://localhost:8000`

## Cloud Deployment

### 🌐 **Live Application**
**TaskFlow is now deployed and accessible at:**
**https://taskflow-app.azurewebsites.net**

### Prerequisites

- Azure CLI configured with appropriate permissions
- Terraform installed
- Docker installed

### Infrastructure Setup

1. **Configure Azure credentials**
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Set up infrastructure variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Application Deployment

1. **Deploy the application**
   ```bash
   # Create deployment package
   zip -r taskflow-deployment.zip . -x "*.git*" "venv/*" "terraform/*" "tests/*" "*.pyc" "__pycache__/*"
   
   # Deploy to Azure App Service
   az webapp deployment source config-zip --resource-group taskflow-rg --name taskflow-app --src taskflow-deployment.zip
   ```

2. **Access your application**
   Visit: https://taskflow-app.azurewebsites.net

### Manual Deployment Steps

If you prefer to deploy manually:

1. **Build and push Docker image**
   ```bash
   # Build Docker image
   docker build -t taskflow-app .
   
   # Run locally for testing
   docker run -p 8000:8000 taskflow-app
   ```

2. **Deploy to Azure App Service**
   ```bash
   # Deploy using Azure CLI
   az webapp deployment source config-zip --resource-group taskflow-rg --name taskflow-app --src taskflow-deployment.zip
   ```

### Running Tests

```bash
# Run all tests
pytest

# Run tests with coverage
pytest --cov=app --cov-report=term-missing

# Run linting
flake8 app/ tests/

# Check code formatting
black --check app/ tests/
```

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration:

- **Automated Testing**: Runs on every push and pull request
- **Code Quality**: Linting with flake8 and formatting checks with black
- **Coverage Reporting**: Generates test coverage reports
- **Database Testing**: Uses MongoDB service container for integration tests

### Branch Protection Rules

The main branch is protected with the following rules:
- Requires pull request reviews
- Requires status checks to pass
- Requires up-to-date branches before merging

## API Endpoints

### 🔗 **API Documentation**
**Interactive API documentation available at:**
**https://taskflow-app.azurewebsites.net/docs**

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/auth/me` - Get current user
- `POST /api/v1/auth/logout` - User logout

### Tasks
- `GET /api/v1/tasks` - List all tasks (with optional status filter)
- `POST /api/v1/tasks` - Create new task
- `GET /api/v1/tasks/{id}` - Get specific task
- `PUT /api/v1/tasks/{id}` - Update task
- `PATCH /api/v1/tasks/{id}/status` - Update task status
- `DELETE /api/v1/tasks/{id}` - Delete task

### Dashboard
- `GET /api/v1/dashboard` - Get dashboard statistics

### Health Checks
- `GET /health` - Main health check
- `GET /api/v1/health` - API health check

### Main
- `GET /` - Landing page
- `GET /dashboard` - User dashboard

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Ademola Emmanuel Oshingbesan**

This project was created as part of an Advanced DevOps course assignment. 