from flask import request, jsonify
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from flask_restx import Api, Resource, Namespace, fields
from app.models import User, Task, db
from datetime import datetime

# Create API instance
api = Api(
    title="TaskFlow API",
    version="1.0",
    description="A comprehensive API for TaskFlow - Personal Task Management",
    doc="/docs",
    authorizations={"apikey": {"type": "apiKey", "in": "header", "name": "X-API-KEY"}},
    security="apikey",
)

# Create namespaces
auth_ns = Namespace("auth", description="Authentication operations")
tasks_ns = Namespace("tasks", description="Task operations")
dashboard_ns = Namespace("dashboard", description="Dashboard operations")

# Add namespaces to API
api.add_namespace(auth_ns)
api.add_namespace(tasks_ns)
api.add_namespace(dashboard_ns)

# Define models for Swagger documentation
user_model = api.model(
    "User",
    {
        "id": fields.Integer(readonly=True, description="User ID"),
        "username": fields.String(required=True, description="Username"),
        "email": fields.String(required=True, description="Email address"),
    },
)

user_register_model = api.model(
    "UserRegister",
    {
        "username": fields.String(required=True, description="Username"),
        "email": fields.String(required=True, description="Email address"),
        "password": fields.String(required=True, description="Password"),
    },
)

user_login_model = api.model(
    "UserLogin",
    {
        "username": fields.String(required=True, description="Username"),
        "password": fields.String(required=True, description="Password"),
    },
)

task_model = api.model(
    "Task",
    {
        "id": fields.Integer(readonly=True, description="Task ID"),
        "title": fields.String(required=True, description="Task title"),
        "description": fields.String(description="Task description"),
        "status": fields.String(enum=["To Do", "In Progress", "Completed"], description="Task status"),
        "created_at": fields.DateTime(readonly=True, description="Creation timestamp"),
        "updated_at": fields.DateTime(readonly=True, description="Last update timestamp"),
    },
)

task_create_model = api.model(
    "TaskCreate",
    {
        "title": fields.String(required=True, description="Task title"),
        "description": fields.String(description="Task description"),
        "status": fields.String(enum=["To Do", "In Progress", "Completed"], default="To Do", description="Task status"),
    },
)

task_update_model = api.model(
    "TaskUpdate",
    {
        "title": fields.String(description="Task title"),
        "description": fields.String(description="Task description"),
        "status": fields.String(enum=["To Do", "In Progress", "Completed"], description="Task status"),
    },
)

status_update_model = api.model(
    "StatusUpdate",
    {"status": fields.String(required=True, enum=["To Do", "In Progress", "Completed"], description="New task status")},
)

dashboard_model = api.model(
    "Dashboard",
    {"stats": fields.Raw(description="Task statistics"), "recent_tasks": fields.List(fields.Raw, description="Recent tasks")},
)


# Authentication endpoints
@auth_ns.route("/register")
class UserRegister(Resource):
    @auth_ns.expect(user_register_model)
    @auth_ns.marshal_with(user_model, code=201)
    @auth_ns.doc(
        responses={
            201: "User registered successfully",
            400: "Missing required fields",
            409: "Username or email already exists",
            500: "Registration failed",
        }
    )
    def post(self):
        """Register a new user"""
        data = request.get_json()

        if not data:
            api.abort(400, "No data provided")

        username = data.get("username")
        email = data.get("email")
        password = data.get("password")

        if not all([username, email, password]):
            api.abort(400, "Missing required fields")

        # Check if user already exists
        if User.query.filter_by(username=username).first():
            api.abort(409, "Username already exists")

        if User.query.filter_by(email=email).first():
            api.abort(409, "Email already exists")

        # Create new user
        user = User(username=username, email=email, password_hash=generate_password_hash(password))

        try:
            db.session.add(user)
            db.session.commit()

            return {"id": user.id, "username": user.username, "email": user.email}, 201
        except Exception as e:
            db.session.rollback()
            api.abort(500, "Registration failed")


@auth_ns.route("/login")
class UserLogin(Resource):
    @auth_ns.expect(user_login_model)
    @auth_ns.marshal_with(user_model)
    @auth_ns.doc(responses={200: "Login successful", 400: "Missing username or password", 401: "Invalid username or password"})
    def post(self):
        """Login user"""
        data = request.get_json()

        if not data:
            api.abort(400, "No data provided")

        username = data.get("username")
        password = data.get("password")

        if not all([username, password]):
            api.abort(400, "Missing username or password")

        user = User.query.filter_by(username=username).first()

        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            return {"id": user.id, "username": user.username, "email": user.email}
        else:
            api.abort(401, "Invalid username or password")


@auth_ns.route("/logout")
class UserLogout(Resource):
    @auth_ns.doc(responses={200: "Logout successful", 401: "Not authenticated"})
    @login_required
    def post(self):
        """Logout user"""
        logout_user()
        return {"message": "Logout successful"}


@auth_ns.route("/me")
class CurrentUser(Resource):
    @auth_ns.marshal_with(user_model)
    @auth_ns.doc(responses={200: "Current user information", 401: "Not authenticated"})
    @login_required
    def get(self):
        """Get current user information"""
        return {"id": current_user.id, "username": current_user.username, "email": current_user.email}


# Task endpoints
@tasks_ns.route("/")
class TaskList(Resource):
    @tasks_ns.marshal_list_with(task_model)
    @tasks_ns.doc(params={"status": "Filter tasks by status (To Do, In Progress, Completed)"})
    @login_required
    def get(self):
        """Get all tasks for current user"""
        status_filter = request.args.get("status")

        query = current_user.tasks

        if status_filter:
            query = query.filter_by(status=status_filter)

        tasks = query.order_by(Task.created_at.desc()).all()

        return [
            {
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "created_at": task.created_at,
                "updated_at": task.updated_at,
            }
            for task in tasks
        ]

    @tasks_ns.expect(task_create_model)
    @tasks_ns.marshal_with(task_model, code=201)
    @login_required
    def post(self):
        """Create a new task"""
        data = request.get_json()

        if not data:
            api.abort(400, "No data provided")

        title = data.get("title")
        description = data.get("description", "")
        status = data.get("status", "To Do")

        if not title:
            api.abort(400, "Title is required")

        # Validate status
        valid_statuses = ["To Do", "In Progress", "Completed"]
        if status not in valid_statuses:
            api.abort(400, "Invalid status")

        task = Task(title=title, description=description, status=status, user_id=current_user.id)

        try:
            db.session.add(task)
            db.session.commit()

            return {
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "created_at": task.created_at,
                "updated_at": task.updated_at,
            }, 201
        except Exception as e:
            db.session.rollback()
            api.abort(500, "Failed to create task")


@tasks_ns.route("/<int:task_id>")
@tasks_ns.param("task_id", "The task identifier")
class TaskResource(Resource):
    @tasks_ns.marshal_with(task_model)
    @login_required
    def get(self, task_id):
        """Get a specific task"""
        task = current_user.tasks.filter_by(id=task_id).first()

        if not task:
            api.abort(404, "Task not found")

        return {
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "status": task.status,
            "created_at": task.created_at,
            "updated_at": task.updated_at,
        }

    @tasks_ns.expect(task_update_model)
    @tasks_ns.marshal_with(task_model)
    @login_required
    def put(self, task_id):
        """Update a task"""
        task = current_user.tasks.filter_by(id=task_id).first()

        if not task:
            api.abort(404, "Task not found")

        data = request.get_json()

        if not data:
            api.abort(400, "No data provided")

        # Update fields if provided
        if "title" in data:
            task.title = data["title"]

        if "description" in data:
            task.description = data["description"]

        if "status" in data:
            valid_statuses = ["To Do", "In Progress", "Completed"]
            if data["status"] not in valid_statuses:
                api.abort(400, "Invalid status")
            task.status = data["status"]

        task.updated_at = datetime.utcnow()

        try:
            db.session.commit()

            return {
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "created_at": task.created_at,
                "updated_at": task.updated_at,
            }
        except Exception as e:
            db.session.rollback()
            api.abort(500, "Failed to update task")

    @login_required
    def delete(self, task_id):
        """Delete a task"""
        task = current_user.tasks.filter_by(id=task_id).first()

        if not task:
            api.abort(404, "Task not found")

        try:
            db.session.delete(task)
            db.session.commit()

            return {"message": "Task deleted successfully"}
        except Exception as e:
            db.session.rollback()
            api.abort(500, "Failed to delete task")


@tasks_ns.route("/<int:task_id>/status")
@tasks_ns.param("task_id", "The task identifier")
class TaskStatus(Resource):
    @tasks_ns.expect(status_update_model)
    @tasks_ns.marshal_with(task_model)
    @login_required
    def patch(self, task_id):
        """Update task status"""
        task = current_user.tasks.filter_by(id=task_id).first()

        if not task:
            api.abort(404, "Task not found")

        data = request.get_json()

        if not data or "status" not in data:
            api.abort(400, "Status is required")

        valid_statuses = ["To Do", "In Progress", "Completed"]
        if data["status"] not in valid_statuses:
            api.abort(400, "Invalid status")

        task.status = data["status"]
        task.updated_at = datetime.utcnow()

        try:
            db.session.commit()

            return {
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "created_at": task.created_at,
                "updated_at": task.updated_at,
            }
        except Exception as e:
            db.session.rollback()
            api.abort(500, "Failed to update task status")


# Dashboard endpoints
@dashboard_ns.route("/")
class Dashboard(Resource):
    @dashboard_ns.marshal_with(dashboard_model)
    @login_required
    def get(self):
        """Get dashboard statistics"""
        total_tasks = current_user.tasks.count()
        todo_tasks = current_user.tasks.filter_by(status="To Do").count()
        in_progress_tasks = current_user.tasks.filter_by(status="In Progress").count()
        completed_tasks = current_user.tasks.filter_by(status="Completed").count()

        recent_tasks = current_user.tasks.order_by(Task.created_at.desc()).limit(5).all()

        return {
            "stats": {
                "total": total_tasks,
                "todo": todo_tasks,
                "in_progress": in_progress_tasks,
                "completed": completed_tasks,
            },
            "recent_tasks": [
                {"id": task.id, "title": task.title, "status": task.status, "created_at": task.created_at.isoformat()}
                for task in recent_tasks
            ],
        }


# Health check endpoint
@api.route("/health")
class HealthCheck(Resource):
    def get(self):
        """API health check"""
        return {"status": "healthy", "service": "taskflow-api", "version": "1.0.0"}
