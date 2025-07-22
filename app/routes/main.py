from flask import Blueprint, render_template, redirect, url_for, jsonify
from flask_login import login_required, current_user
from app.models import Task

main_bp = Blueprint("main", __name__)


@main_bp.route("/")
def index():
    if current_user.is_authenticated:
        return redirect(url_for("main.dashboard"))
    return render_template("main/index.html")


@main_bp.route("/health")
def health():
    """Health check endpoint for container orchestration"""
    return jsonify({"status": "healthy", "service": "taskflow"})


@main_bp.route("/dashboard")
@login_required
def dashboard():
    # Get task statistics
    total_tasks = Task.objects(user=current_user).count()
    todo_tasks = Task.objects(user=current_user, status="To Do").count()
    in_progress_tasks = Task.objects(user=current_user, status="In Progress").count()
    completed_tasks = Task.objects(user=current_user, status="Completed").count()

    # Get recent tasks
    recent_tasks = Task.objects(user=current_user).order_by("-created_at").limit(5)

    stats = {"total": total_tasks, "todo": todo_tasks, "in_progress": in_progress_tasks, "completed": completed_tasks}

    return render_template("main/dashboard.html", stats=stats, recent_tasks=recent_tasks)
