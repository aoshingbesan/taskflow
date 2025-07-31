# TaskFlow - Personal Task Management Application

A Flask-based web application for personal task management with user authentication, task CRUD operations, and RESTful API.

## Features

- **User Authentication**: Register, login, and logout functionality
- **Task Management**: Create, read, update, and delete tasks
- **Dashboard**: Overview of tasks and statistics
- **RESTful API**: Complete API with Swagger documentation
- **MongoDB Integration**: Cloud database with MongoDB Atlas
- **Azure Deployment**: Staging and production environments

## Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/aoshingbesan/taskflow.git
   cd taskflow
   ```

2. **Set up virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   python main_app.py
   ```

5. **Access the application**
   - Open http://localhost:5000 in your browser
   - Register a new account and start managing tasks

## Deployment Status

### ✅ Working Environments
- **Staging**: https://taskflow-staging.azurewebsites.net (Fully Functional)
- **Production**: https://taskflow-app.azurewebsites.net (Deployment in Progress)

### 🔧 Technical Stack
- **Backend**: Flask 2.3.3
- **Database**: MongoDB Atlas
- **ORM**: MongoEngine
- **Authentication**: Flask-Login
- **API**: Flask-RESTX
- **Cloud**: Azure App Service
- **CI/CD**: GitHub Actions

## API Documentation

Access the interactive API documentation at `/docs` when running the application.

## Testing

Run the test suite:
```bash
pytest tests/ -v
```

## License

MIT License

---
*Last updated: Production deployment in progress - staging environment fully functional*
# Production Environment Recreated
# Production Environment Recreated - Final Fix
# Staging deployment test

trigger trigger