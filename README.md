# TaskFlow - Personal Task Management

<!-- CI Pipeline Test: This comment was added to test the GitHub Actions workflow -->
<!-- Branch Protection Test: Testing the complete workflow with branch protection -->

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
- **Database**: PostgreSQL
- **Authentication**: Flask-Login with password hashing
- **Testing**: pytest with coverage reporting
- **CI/CD**: GitHub Actions with automated testing and linting

## Project Structure

```
taskflow/
├── app/
│   ├── __init__.py          # Flask application factory
│   ├── models.py            # Database models (User, Task)
│   ├── routes/
│   │   ├── auth.py          # Authentication routes
│   │   ├── main.py          # Main routes (dashboard, index)
│   │   └── tasks.py         # Task management routes
│   ├── static/              # CSS, JS, and static assets
│   └── templates/           # HTML templates
│       ├── auth/            # Login and registration templates
│       ├── main/            # Dashboard and index templates
│       └── tasks/           # Task management templates
├── tests/
│   └── unit/               # Unit tests
├── config.py               # Application configuration
├── app.py                  # Application entry point
├── requirements.txt        # Python dependencies
└── README.md              # This file
```

## Local Development Setup

### Prerequisites

- Python 3.9 or higher
- PostgreSQL database
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
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
   DATABASE_URL=postgresql://username:password@localhost/taskflow
   ```

5. **Set up the database**
   ```bash
   # Create PostgreSQL database
   createdb taskflow
   
   # Initialize database tables
   flask db init
   flask db migrate -m "Initial migration"
   flask db upgrade
   ```

6. **Run the application**
   ```bash
   python app.py
   ```

7. **Access the application**
   Open your browser and navigate to `http://localhost:8000`

## Docker Setup

### Prerequisites

- Docker and Docker Compose
- Git

### Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd taskflow
   ```

2. **Build and run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   Open your browser and navigate to `http://localhost:8000`

4. **Stop the containers**
   ```bash
   docker-compose down
   ```

### Docker Commands

```bash
# Build the Docker image
docker build -t taskflow .

# Run the container locally
docker run -p 8000:8000 taskflow

# Run with environment variables
docker run -p 8000:8000 \
  -e DATABASE_URL=postgresql://user:pass@host/db \
  -e SECRET_KEY=your-secret-key \
  taskflow
```

## Cloud Deployment

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Docker installed

### Infrastructure Setup

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Set up infrastructure variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy infrastructure**
   ```bash
   ./scripts/setup-infrastructure.sh
   ```

### Application Deployment

1. **Deploy the application**
   ```bash
   ./scripts/deploy.sh
   ```

2. **Access your application**
   The script will output the public URL of your application.

### Manual Deployment Steps

If you prefer to deploy manually:

1. **Build and push Docker image**
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
   ```

2. **Update ECS service**
   ```bash
   aws ecs update-service \
     --cluster taskflow-cluster \
     --service taskflow-service \
     --force-new-deployment \
     --region us-east-1
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
- **Database Testing**: Uses PostgreSQL service container for integration tests

### Branch Protection Rules

The main branch is protected with the following rules:
- Requires pull request reviews
- Requires status checks to pass
- Requires up-to-date branches before merging

## API Endpoints

### Authentication
- `GET/POST /register` - User registration
- `GET/POST /login` - User login
- `GET /logout` - User logout

### Tasks
- `GET /tasks` - List all tasks (with optional status filter)
- `GET/POST /tasks/new` - Create new task
- `GET/POST /tasks/<id>/edit` - Edit existing task
- `POST /tasks/<id>/delete` - Delete task
- `POST /tasks/<id>/status` - Update task status

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

## Phase 2: Containerization, IaC & Manual Deployment

### ✅ Completed Features:
- **Containerization**: Dockerfile and docker-compose.yml working
- **Swagger UI API**: Interactive documentation at `/docs`
- **Infrastructure as Code**: Terraform configurations ready
- **CI/CD Pipeline**: All tests passing, code formatted
- **Deployment Scripts**: AWS automation ready

### 🚀 Ready for Deployment:
- Local Docker setup: `docker-compose up`
- Swagger UI: http://localhost:8000/docs
- All tests passing ✅
- Code formatting compliant ✅

### 📋 Next Steps:
- AWS infrastructure deployment
- Manual cloud deployment
- Peer review completion 