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
    """Comprehensive health check endpoint for Azure App Service monitoring"""
    from datetime import datetime
    import os
    import mongoengine
    
        health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": os.environ.get("APP_VERSION", "1.0"),
        "checks": {},
    }
    try:
        # Test database connectivity
        if mongoengine.connection.get_db():
            health_status["checks"]["database"] = {"status": "healthy"}
                else:
            health_status["checks"]["database"] = {"status": "unhealthy", "error": "No database connection"}
            health_status["status"] = "unhealthy"
        # Check resource usage (if available)
        try:
            import psutil

            cpu_percent = psutil.cpu_percent(interval=1)
            memory_percent = psutil.virtual_memory().percent

            health_status["checks"]["resources"] = {
                "cpu_percent": cpu_percent,
                "memory_percent": memory_percent,
                "status": "healthy" if cpu_percent < 80 and memory_percent < 85 else "warning",
            }
                except ImportError:
            health_status["checks"]["resources"] = {"status": "not_available"}
        # Check environment variables
        health_status["checks"]["environment"] = {
            "mongodb_uri_set": bool(os.environ.get("MONGODB_URI")),
            "flask_env": os.environ.get("FLASK_ENV", "not_set"),
            "websites_port": os.environ.get("WEBSITES_PORT", "not_set"),
            "status": "healthy",
        }

        return jsonify(health_status), 200 if health_status["status"] == "healthy" else 503

    except Exception as e:
        health_status["status"] = "unhealthy"
        health_status["error"] = str(e)
        return jsonify(health_status), 503


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
