from flask import Blueprint, render_template, redirect, url_for, flash, request, jsonify
from flask_login import login_required, current_user
from app.models import Task
from app import db

tasks_bp = Blueprint('tasks', __name__)

@tasks_bp.route('/tasks')
@login_required
def task_list():
    status_filter = request.args.get('status', 'all')
    
    if status_filter == 'all':
        tasks = current_user.tasks.order_by(Task.created_at.desc()).all()
    else:
        tasks = current_user.tasks.filter_by(status=status_filter).order_by(Task.created_at.desc()).all()
    
    return render_template('tasks/list.html', tasks=tasks, current_filter=status_filter)

@tasks_bp.route('/tasks/new', methods=['GET', 'POST'])
@login_required
def create_task():
    if request.method == 'POST':
        title = request.form.get('title')
        description = request.form.get('description')
        status = request.form.get('status', 'To Do')
        
        if not title:
            flash('Task title is required.', 'error')
            return render_template('tasks/create.html')
        
        task = Task(
            title=title,
            description=description,
            status=status,
            user_id=current_user.id
        )
        
        db.session.add(task)
        db.session.commit()
        
        flash('Task created successfully!', 'success')
        return redirect(url_for('tasks.task_list'))
    
    return render_template('tasks/create.html')

@tasks_bp.route('/tasks/<int:task_id>/edit', methods=['GET', 'POST'])
@login_required
def edit_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    if task.user_id != current_user.id:
        flash('You can only edit your own tasks.', 'error')
        return redirect(url_for('tasks.task_list'))
    
    if request.method == 'POST':
        task.title = request.form.get('title')
        task.description = request.form.get('description')
        task.status = request.form.get('status')
        
        if not task.title:
            flash('Task title is required.', 'error')
            return render_template('tasks/edit.html', task=task)
        
        db.session.commit()
        flash('Task updated successfully!', 'success')
        return redirect(url_for('tasks.task_list'))
    
    return render_template('tasks/edit.html', task=task)

@tasks_bp.route('/tasks/<int:task_id>/delete', methods=['POST'])
@login_required
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    
    if task.user_id != current_user.id:
        flash('You can only delete your own tasks.', 'error')
        return redirect(url_for('tasks.task_list'))
    
    db.session.delete(task)
    db.session.commit()
    
    flash('Task deleted successfully!', 'success')
    return redirect(url_for('tasks.task_list'))

@tasks_bp.route('/tasks/<int:task_id>/status', methods=['POST'])
@login_required
def update_status(task_id):
    task = Task.query.get_or_404(task_id)
    
    if task.user_id != current_user.id:
        return jsonify({'error': 'Unauthorized'}), 403
    
    new_status = request.json.get('status')
    if new_status in ['To Do', 'In Progress', 'Completed']:
        task.status = new_status
        db.session.commit()
        return jsonify({'success': True, 'status': new_status})
    
    return jsonify({'error': 'Invalid status'}), 400 