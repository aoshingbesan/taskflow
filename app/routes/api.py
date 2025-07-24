from flask import Blueprint, request, jsonify
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from app.models import User, Task
from datetime import datetime

api_bp = Blueprint("api", __name__, url_prefix="/api/v1")


# Authentication endpoints
@api_bp.route("/auth/register", methods=["POST"])
def register():
    """Register a new user"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    username = data.get("username")
    email = data.get("email")
    password = data.get("password")

    if not all([username, email, password]):
        return jsonify({"error": "Missing required fields"}), 400

    # Check if user already exists
    if User.objects(username=username).first():
        return jsonify({"error": "Username already exists"}), 409

    if User.objects(email=email).first():
        return jsonify({"error": "Email already exists"}), 409

    # Create new user
    user = User(username=username, email=email)
    user.set_password(password)

    try:
        user.save()

        return (
            jsonify(
                {
                    "message": "User registered successfully",
                    "user": {"id": str(user.id), "username": user.username, "email": user.email},
                }
            ),
            201,
        )
    except Exception as e:
        return jsonify({"error": "Registration failed"}), 500


@api_bp.route("/auth/login", methods=["POST"])
def login():
    """Login user"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    username = data.get("username")
    password = data.get("password")

    if not all([username, password]):
        return jsonify({"error": "Missing username or password"}), 400

    user = User.objects(username=username).first()

    if user and user.check_password(password):
        login_user(user)
        return (
            jsonify(
                {"message": "Login successful", "user": {"id": str(user.id), "username": user.username, "email": user.email}}
            ),
            200,
        )
    else:
        return jsonify({"error": "Invalid username or password"}), 401


@api_bp.route("/auth/logout", methods=["POST"])
@login_required
def logout():
    """Logout user"""
    logout_user()
    return jsonify({"message": "Logout successful"}), 200


@api_bp.route("/auth/me", methods=["GET"])
@login_required
def get_current_user():
    """Get current user information"""
    return jsonify({"user": {"id": current_user.id, "username": current_user.username, "email": current_user.email}}), 200


# Task endpoints
@api_bp.route("/tasks", methods=["GET"])
@login_required
def get_tasks():
    """Get all tasks for current user"""
    status_filter = request.args.get("status")

    if status_filter:
        tasks = Task.objects(user=current_user, status=status_filter).order_by("-created_at")
    else:
        tasks = Task.objects(user=current_user).order_by("-created_at")

    return (
        jsonify(
            {
                "tasks": [
                    {
                        "id": str(task.id),
                        "title": task.title,
                        "description": task.description,
                        "status": task.status,
                        "created_at": task.created_at.isoformat(),
                        "updated_at": task.updated_at.isoformat() if task.updated_at else None,
                    }
                    for task in tasks
                ]
            }
        ),
        200,
    )


@api_bp.route("/tasks", methods=["POST"])
@login_required
def create_task():
    """Create a new task"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    title = data.get("title")
    description = data.get("description", "")
    status = data.get("status", "To Do")

    if not title:
        return jsonify({"error": "Title is required"}), 400

    # Validate status
    valid_statuses = ["To Do", "In Progress", "Completed"]
    if status not in valid_statuses:
        return jsonify({"error": "Invalid status"}), 400

    task = Task(title=title, description=description, status=status, user=current_user)

    try:
        task.save()

        return (
            jsonify(
                {
                    "message": "Task created successfully",
                    "task": {
                        "id": str(task.id),
                        "title": task.title,
                        "description": task.description,
                        "status": task.status,
                        "created_at": task.created_at.isoformat(),
                        "updated_at": task.updated_at.isoformat() if task.updated_at else None,
                    },
                }
            ),
            201,
        )
    except Exception as e:
        return jsonify({"error": "Failed to create task"}), 500


@api_bp.route("/tasks/<task_id>", methods=["GET"])
@login_required
def get_task(task_id):
    """Get a specific task"""
    task = Task.objects(id=task_id, user=current_user).first()

    if not task:
        return jsonify({"error": "Task not found"}), 404

    return (
        jsonify(
            {
                "task": {
                    "id": str(task.id),
                    "title": task.title,
                    "description": task.description,
                    "status": task.status,
                    "created_at": task.created_at.isoformat(),
                    "updated_at": task.updated_at.isoformat() if task.updated_at else None,
                }
            }
        ),
        200,
    )


@api_bp.route("/tasks/<task_id>", methods=["PUT"])
@login_required
def update_task(task_id):
    """Update a task"""
    task = Task.objects(id=task_id, user=current_user).first()

    if not task:
        return jsonify({"error": "Task not found"}), 404

    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    # Update fields if provided
    if "title" in data:
        task.title = data["title"]

    if "description" in data:
        task.description = data["description"]

    if "status" in data:
        valid_statuses = ["To Do", "In Progress", "Completed"]
        if data["status"] not in valid_statuses:
            return jsonify({"error": "Invalid status"}), 400
        task.status = data["status"]

    task.updated_at = datetime.utcnow()

    try:
        task.save()

        return (
            jsonify(
                {
                    "message": "Task updated successfully",
                    "task": {
                        "id": str(task.id),
                        "title": task.title,
                        "description": task.description,
                        "status": task.status,
                        "created_at": task.created_at.isoformat(),
                        "updated_at": task.updated_at.isoformat() if task.updated_at else None,
                    },
                }
            ),
            200,
        )
    except Exception as e:
        return jsonify({"error": "Failed to update task"}), 500


@api_bp.route("/tasks/<task_id>", methods=["DELETE"])
@login_required
def delete_task(task_id):
    """Delete a task"""
    task = Task.objects(id=task_id, user=current_user).first()

    if not task:
        return jsonify({"error": "Task not found"}), 404

    try:
        task.delete()

        return jsonify({"message": "Task deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": "Failed to delete task"}), 500


@api_bp.route("/tasks/<task_id>/status", methods=["PATCH"])
@login_required
def update_task_status(task_id):
    """Update task status"""
    task = Task.objects(id=task_id, user=current_user).first()

    if not task:
        return jsonify({"error": "Task not found"}), 404

    data = request.get_json()

    if not data or "status" not in data:
        return jsonify({"error": "Status is required"}), 400

    valid_statuses = ["To Do", "In Progress", "Completed"]
    if data["status"] not in valid_statuses:
        return jsonify({"error": "Invalid status"}), 400

    task.status = data["status"]
    task.updated_at = datetime.utcnow()

    try:
        task.save()

        return (
            jsonify(
                {
                    "message": "Task status updated successfully",
                    "task": {
                        "id": str(task.id),
                        "title": task.title,
                        "description": task.description,
                        "status": task.status,
                        "created_at": task.created_at.isoformat(),
                        "updated_at": task.updated_at.isoformat() if task.updated_at else None,
                    },
                }
            ),
            200,
        )
    except Exception as e:
        return jsonify({"error": "Failed to update task status"}), 500


# Dashboard endpoints
@api_bp.route("/dashboard", methods=["GET"])
@login_required
def get_dashboard():
    """Get dashboard statistics"""
    total_tasks = Task.objects(user=current_user).count()
    todo_tasks = Task.objects(user=current_user, status="To Do").count()
    in_progress_tasks = Task.objects(user=current_user, status="In Progress").count()
    completed_tasks = Task.objects(user=current_user, status="Completed").count()

    recent_tasks = Task.objects(user=current_user).order_by("-created_at").limit(5)

    return (
        jsonify(
            {
                "stats": {
                    "total": total_tasks,
                    "todo": todo_tasks,
                    "in_progress": in_progress_tasks,
                    "completed": completed_tasks,
                },
                "recent_tasks": [
                    {"id": str(task.id), "title": task.title, "status": task.status, "created_at": task.created_at.isoformat()}
                    for task in recent_tasks
                ],
            }
        ),
        200,
    )


# Health check endpoint
@api_bp.route("/health", methods=["GET"])
def health_check():
    """API health check"""
    return jsonify({"status": "healthy", "service": "taskflow-api", "version": "1.0.0"}), 200
