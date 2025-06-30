from flask import Blueprint, render_template, redirect, url_for
from flask_login import login_required, current_user
from app.models import Task

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    if current_user.is_authenticated:
        return redirect(url_for('main.dashboard'))
    return render_template('main/index.html')

@main_bp.route('/dashboard')
@login_required
def dashboard():
    # Get task statistics
    total_tasks = current_user.tasks.count()
    todo_tasks = current_user.tasks.filter_by(status='To Do').count()
    in_progress_tasks = current_user.tasks.filter_by(status='In Progress').count()
    completed_tasks = current_user.tasks.filter_by(status='Completed').count()
    
    # Get recent tasks
    recent_tasks = current_user.tasks.order_by(Task.created_at.desc()).limit(5).all()
    
    stats = {
        'total': total_tasks,
        'todo': todo_tasks,
        'in_progress': in_progress_tasks,
        'completed': completed_tasks
    }
    
    return render_template('main/dashboard.html', stats=stats, recent_tasks=recent_tasks) 