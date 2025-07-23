# TaskFlow API Documentation

## Base URL
```
http://localhost:8000/api/v1
```

## Authentication
Most endpoints require authentication. After login, you'll receive a session cookie that should be included in subsequent requests.

## Endpoints

### Authentication

#### Register User
**POST** `/api/v1/auth/register`

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response (201 Created):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

#### Login User
**POST** `/api/v1/auth/login`

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "securepassword"
}
```

**Response (200 OK):**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

#### Logout User
**POST** `/api/v1/auth/logout`

**Response (200 OK):**
```json
{
  "message": "Logout successful"
}
```

#### Get Current User
**GET** `/api/v1/auth/me`

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

### Tasks

#### Get All Tasks
**GET** `/api/v1/tasks`

**Query Parameters:**
- `status` (optional): Filter by status ("To Do", "In Progress", "Completed")

**Response (200 OK):**
```json
{
  "tasks": [
    {
      "id": 1,
      "title": "Complete project",
      "description": "Finish the TaskFlow project",
      "status": "In Progress",
      "created_at": "2024-01-15T10:30:00",
      "updated_at": "2024-01-15T14:45:00"
    }
  ]
}
```

#### Create Task
**POST** `/api/v1/tasks`

**Request Body:**
```json
{
  "title": "New Task",
  "description": "Task description",
  "status": "To Do"
}
```

**Response (201 Created):**
```json
{
  "message": "Task created successfully",
  "task": {
    "id": 2,
    "title": "New Task",
    "description": "Task description",
    "status": "To Do",
    "created_at": "2024-01-15T16:00:00",
    "updated_at": null
  }
}
```

#### Get Specific Task
**GET** `/api/v1/tasks/{task_id}`

**Response (200 OK):**
```json
{
  "task": {
    "id": 1,
    "title": "Complete project",
    "description": "Finish the TaskFlow project",
    "status": "In Progress",
    "created_at": "2024-01-15T10:30:00",
    "updated_at": "2024-01-15T14:45:00"
  }
}
```

#### Update Task
**PUT** `/api/v1/tasks/{task_id}`

**Request Body:**
```json
{
  "title": "Updated Task Title",
  "description": "Updated description",
  "status": "Completed"
}
```

**Response (200 OK):**
```json
{
  "message": "Task updated successfully",
  "task": {
    "id": 1,
    "title": "Updated Task Title",
    "description": "Updated description",
    "status": "Completed",
    "created_at": "2024-01-15T10:30:00",
    "updated_at": "2024-01-15T16:30:00"
  }
}
```

#### Delete Task
**DELETE** `/api/v1/tasks/{task_id}`

**Response (200 OK):**
```json
{
  "message": "Task deleted successfully"
}
```

#### Update Task Status
**PATCH** `/api/v1/tasks/{task_id}/status`

**Request Body:**
```json
{
  "status": "Completed"
}
```

**Response (200 OK):**
```json
{
  "message": "Task status updated successfully",
  "task": {
    "id": 1,
    "title": "Complete project",
    "description": "Finish the TaskFlow project",
    "status": "Completed",
    "created_at": "2024-01-15T10:30:00",
    "updated_at": "2024-01-15T16:30:00"
  }
}
```

### Dashboard

#### Get Dashboard Statistics
**GET** `/api/v1/dashboard`

**Response (200 OK):**
```json
{
  "stats": {
    "total": 10,
    "todo": 3,
    "in_progress": 4,
    "completed": 3
  },
  "recent_tasks": [
    {
      "id": 1,
      "title": "Complete project",
      "status": "In Progress",
      "created_at": "2024-01-15T10:30:00"
    }
  ]
}
```

### Health Check

#### API Health Check
**GET** `/api/v1/health`

**Response (200 OK):**
```json
{
  "status": "healthy",
  "service": "taskflow-api",
  "version": "1.0.0"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Missing required fields"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid username or password"
}
```

### 404 Not Found
```json
{
  "error": "Task not found"
}
```

### 409 Conflict
```json
{
  "error": "Username already exists"
}
```

### 500 Internal Server Error
```json
{
  "error": "Registration failed"
}
```

## Status Codes

- **To Do**: Initial status for new tasks
- **In Progress**: Task is being worked on
- **Completed**: Task is finished

## Testing with curl

### Register a user
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }' \
  -c cookies.txt
```

### Create a task
```bash
curl -X POST http://localhost:8000/api/v1/tasks \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "title": "Test Task",
    "description": "This is a test task",
    "status": "To Do"
  }'
```

### Get all tasks
```bash
curl -X GET http://localhost:8000/api/v1/tasks \
  -b cookies.txt
```

### Get dashboard
```bash
curl -X GET http://localhost:8000/api/v1/dashboard \
  -b cookies.txt
``` 