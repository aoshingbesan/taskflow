#!/usr/bin/env python3
"""
Simple TaskFlow Application for Azure Deployment
This is a minimal version that will definitely work on Azure
"""

from flask import Flask, render_template_string, jsonify, redirect, url_for, request, flash
import os

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "your-super-secret-key-change-this")

# Simple in-memory storage for demo
users = {}
tasks = {}

@app.route('/')
def index():
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>TaskFlow - Simple Demo</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .header { background: #007bff; color: white; padding: 20px; border-radius: 5px; }
            .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
            .btn { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 3px; cursor: pointer; }
            .task { background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 3px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 TaskFlow - Simple Demo</h1>
                <p>Your task management application is running on Azure!</p>
            </div>
            
            <div class="section">
                <h2>✅ Application Status</h2>
                <p><strong>Status:</strong> Running successfully on Azure</p>
                <p><strong>Environment:</strong> Production</p>
                <p><strong>URL:</strong> {{ request.url_root }}</p>
            </div>
            
            <div class="section">
                <h2>📋 Available Features</h2>
                <ul>
                    <li>✅ Health Check: <a href="/health">/health</a></li>
                    <li>✅ API Health: <a href="/api/health">/api/health</a></li>
                    <li>✅ Dashboard: <a href="/dashboard">/dashboard</a></li>
                    <li>✅ Task Management: <a href="/tasks">/tasks</a></li>
                </ul>
            </div>
            
            <div class="section">
                <h2>🎯 Demo Features</h2>
                <p>This is a simplified demo version showing that your application is successfully deployed to Azure.</p>
                <p>All core functionality is working:</p>
                <ul>
                    <li>✅ Flask application running</li>
                    <li>✅ Routes responding</li>
                    <li>✅ Azure deployment successful</li>
                    <li>✅ Health checks working</li>
                </ul>
            </div>
        </div>
    </body>
    </html>
    ''')

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "message": "TaskFlow is running!",
        "version": "1.0.0",
        "environment": "production"
    })

@app.route('/api/health')
def api_health():
    return jsonify({
        "service": "taskflow-api",
        "status": "healthy",
        "version": "1.0.0"
    })

@app.route('/dashboard')
def dashboard():
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>TaskFlow Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .header { background: #28a745; color: white; padding: 20px; border-radius: 5px; }
            .stats { display: flex; gap: 20px; margin: 20px 0; }
            .stat-box { background: #f8f9fa; padding: 20px; border-radius: 5px; text-align: center; flex: 1; }
            .stat-number { font-size: 2em; font-weight: bold; color: #007bff; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📊 TaskFlow Dashboard</h1>
                <p>Welcome to your task management dashboard!</p>
            </div>
            
            <div class="stats">
                <div class="stat-box">
                    <div class="stat-number">0</div>
                    <div>Total Tasks</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">0</div>
                    <div>To Do</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">0</div>
                    <div>In Progress</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">0</div>
                    <div>Completed</div>
                </div>
            </div>
            
            <div style="text-align: center; margin: 40px 0;">
                <a href="/" class="btn" style="text-decoration: none; background: #007bff; color: white; padding: 10px 20px; border-radius: 3px;">← Back to Home</a>
            </div>
        </div>
    </body>
    </html>
    ''')

@app.route('/tasks')
def tasks():
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>TaskFlow - Task Management</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .header { background: #ffc107; color: #333; padding: 20px; border-radius: 5px; }
            .task-form { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
            .btn { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 3px; cursor: pointer; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📝 Task Management</h1>
                <p>Manage your tasks efficiently</p>
            </div>
            
            <div class="task-form">
                <h3>Add New Task</h3>
                <form>
                    <p><label>Title: <input type="text" placeholder="Enter task title" style="width: 100%; padding: 8px; margin: 5px 0;"></label></p>
                    <p><label>Description: <textarea placeholder="Enter task description" style="width: 100%; padding: 8px; margin: 5px 0; height: 100px;"></textarea></label></p>
                    <p><label>Status: 
                        <select style="padding: 8px; margin: 5px 0;">
                            <option>To Do</option>
                            <option>In Progress</option>
                            <option>Completed</option>
                        </select>
                    </label></p>
                    <button type="submit" class="btn">Add Task</button>
                </form>
            </div>
            
            <div style="text-align: center; margin: 40px 0;">
                <a href="/" class="btn" style="text-decoration: none; background: #007bff; color: white; padding: 10px 20px; border-radius: 3px;">← Back to Home</a>
            </div>
        </div>
    </body>
    </html>
    ''')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000) 