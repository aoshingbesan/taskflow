from flask import Blueprint, render_template, redirect, url_for, flash, request, jsonify
from flask_login import login_required, current_user
from app.models import Task

tasks_bp = Blueprint("tasks", __name__)


@tasks_bp.route("/tasks")
@login_required
def task_list():
    status_filter = request.args.get("status", "all")

    if status_filter == "all":
        tasks = Task.objects(user=current_user).order_by("-created_at")
    else:
        tasks = Task.objects(user=current_user, status=status_filter).order_by("-created_at")

    return render_template("tasks/list.html", tasks=tasks, current_filter=status_filter)


@tasks_bp.route("/tasks/new", methods=["GET", "POST"])
@login_required
def create_task():
    if request.method == "POST":
        title = request.form.get("title")
        description = request.form.get("description")
        status = request.form.get("status", "To Do")

        if not title:
            flash("Task title is required.", "error")
            return render_template("tasks/create.html")

        task = Task(title=title, description=description, status=status, user=current_user)
        task.save()

        flash("Task created successfully!", "success")
        return redirect(url_for("tasks.task_list"))

    return render_template("tasks/create.html")


@tasks_bp.route("/tasks/<task_id>/edit", methods=["GET", "POST"])
@login_required
def edit_task(task_id):
    task = Task.objects(id=task_id).first_or_404()

    if task.user != current_user:
        flash("You can only edit your own tasks.", "error")
        return redirect(url_for("tasks.task_list"))

    if request.method == "POST":
        task.title = request.form.get("title")
        task.description = request.form.get("description")
        task.status = request.form.get("status")

        if not task.title:
            flash("Task title is required.", "error")
            return render_template("tasks/edit.html", task=task)

        task.save()
        flash("Task updated successfully!", "success")
        return redirect(url_for("tasks.task_list"))

    return render_template("tasks/edit.html", task=task)


@tasks_bp.route("/tasks/<task_id>/delete", methods=["POST"])
@login_required
def delete_task(task_id):
    task = Task.objects(id=task_id).first_or_404()

    if task.user != current_user:
        flash("You can only delete your own tasks.", "error")
        return redirect(url_for("tasks.task_list"))

    task.delete()
    flash("Task deleted successfully!", "success")
    return redirect(url_for("tasks.task_list"))


@tasks_bp.route("/tasks/<task_id>/status", methods=["POST"])
@login_required
def update_status(task_id):
    task = Task.objects(id=task_id).first_or_404()

    if task.user != current_user:
        return jsonify({"error": "Unauthorized"}), 403

    new_status = request.json.get("status")
    if new_status in ["To Do", "In Progress", "Completed"]:
        task.status = new_status
        task.save()
        return jsonify({"success": True, "status": new_status})

    return jsonify({"error": "Invalid status"}), 400
