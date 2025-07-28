"""
Monitoring and Observability Module for TaskFlow

This module provides comprehensive monitoring, logging, and alerting capabilities
for the TaskFlow application following DevSecOps best practices.
"""

import logging
import time
import functools
from datetime import datetime
from flask import request, g, current_app
from werkzeug.exceptions import HTTPException
import json


# Configure structured logging
def setup_logging(app):
    """Configure comprehensive logging for the application."""

    # Create formatter for structured logging
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")

    # Configure file handler
    file_handler = logging.FileHandler("taskflow.log")
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)

    # Configure console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    # Configure application logger
    app.logger.addHandler(file_handler)
    app.logger.addHandler(console_handler)
    app.logger.setLevel(logging.INFO)

    # Log application startup
    app.logger.info("TaskFlow application started")
    app.logger.info(f"Environment: {app.config.get('ENV', 'development')}")
    app.logger.info(f"Debug mode: {app.debug}")


def log_request_info():
    """Log detailed request information for monitoring."""
    if request:
        g.start_time = time.time()
        current_app.logger.info(
            f"Request: {request.method} {request.path} - "
            f"IP: {request.remote_addr} - "
            f"User-Agent: {request.headers.get('User-Agent', 'Unknown')}"
        )


def log_response_info(response):
    """Log response information and performance metrics."""
    if hasattr(g, "start_time"):
        duration = time.time() - g.start_time
        current_app.logger.info(f"Response: {response.status_code} - " f"Duration: {duration:.3f}s - " f"Path: {request.path}")

        # Log slow requests (over 2 seconds)
        if duration > 2.0:
            current_app.logger.warning(f"Slow request detected: {request.path} took {duration:.3f}s")

    return response


def log_error(error):
    """Log error information with context."""
    if isinstance(error, HTTPException):
        current_app.logger.error(
            f"HTTP Error {error.code}: {error.description} - " f"Path: {request.path if request else 'Unknown'}"
        )
    else:
        current_app.logger.error(f"Application Error: {str(error)} - " f"Path: {request.path if request else 'Unknown'}")


def log_security_event(event_type, details):
    """Log security-related events for monitoring."""
    security_log = {
        "timestamp": datetime.utcnow().isoformat(),
        "event_type": event_type,
        "details": details,
        "ip_address": request.remote_addr if request else "Unknown",
        "user_agent": request.headers.get("User-Agent", "Unknown") if request else "Unknown",
    }

    current_app.logger.warning(f"Security Event: {json.dumps(security_log)}")


def log_database_operation(operation, collection, duration=None, success=True):
    """Log database operations for performance monitoring."""
    log_data = {"operation": operation, "collection": collection, "success": success, "duration": duration}

    if duration and duration > 1.0:  # Log slow database operations
        current_app.logger.warning(f"Slow DB operation: {json.dumps(log_data)}")
    else:
        current_app.logger.info(f"DB operation: {json.dumps(log_data)}")


def log_user_activity(user_id, action, details=None):
    """Log user activities for audit trail."""
    activity_log = {
        "user_id": user_id,
        "action": action,
        "timestamp": datetime.utcnow().isoformat(),
        "ip_address": request.remote_addr if request else "Unknown",
        "details": details,
    }

    current_app.logger.info(f"User Activity: {json.dumps(activity_log)}")


def log_api_usage(endpoint, method, status_code, duration=None):
    """Log API usage for monitoring and analytics."""
    api_log = {
        "endpoint": endpoint,
        "method": method,
        "status_code": status_code,
        "duration": duration,
        "timestamp": datetime.utcnow().isoformat(),
    }

    current_app.logger.info(f"API Usage: {json.dumps(api_log)}")


# Performance monitoring decorator
def monitor_performance(func):
    """Decorator to monitor function performance."""

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start_time

            # Log performance metrics
            current_app.logger.info(f"Function {func.__name__} completed in {duration:.3f}s")

            # Alert on slow operations
            if duration > 5.0:
                current_app.logger.warning(f"Slow function detected: {func.__name__} took {duration:.3f}s")

            return result
        except Exception as e:
            duration = time.time() - start_time
            current_app.logger.error(f"Function {func.__name__} failed after {duration:.3f}s: {str(e)}")
            raise

    return wrapper


# Health check monitoring
class HealthMonitor:
    """Monitor application health and generate alerts."""

    def __init__(self, app):
        self.app = app
        self.health_checks = {}
        self.last_check = None

    def register_health_check(self, name, check_func):
        """Register a health check function."""
        self.health_checks[name] = check_func

    def run_health_checks(self):
        """Run all registered health checks."""
        results = {}
        overall_status = "healthy"

        for name, check_func in self.health_checks.items():
            try:
                result = check_func()
                results[name] = {"status": "healthy" if result else "unhealthy", "timestamp": datetime.utcnow().isoformat()}

                if not result:
                    overall_status = "unhealthy"
                    current_app.logger.error(f"Health check failed: {name}")

            except Exception as e:
                results[name] = {"status": "error", "error": str(e), "timestamp": datetime.utcnow().isoformat()}
                overall_status = "unhealthy"
                current_app.logger.error(f"Health check error: {name} - {str(e)}")

        self.last_check = {"overall_status": overall_status, "checks": results, "timestamp": datetime.utcnow().isoformat()}

        return self.last_check

    def get_health_status(self):
        """Get the current health status."""
        if not self.last_check:
            return self.run_health_checks()
        return self.last_check


# Initialize monitoring
def init_monitoring(app):
    """Initialize all monitoring components."""
    setup_logging(app)

    # Register request/response logging
    app.before_request(log_request_info)
    app.after_request(log_response_info)

    # Register error logging
    app.register_error_handler(Exception, log_error)

    # Initialize health monitor
    health_monitor = HealthMonitor(app)
    app.health_monitor = health_monitor

    # Register basic health checks
    def check_database():
        """Check database connectivity."""
        try:
            from app.models import User

            User.objects.first()
            return True
        except Exception as e:
            current_app.logger.error(f"Database health check failed: {str(e)}")
            return False

    def check_redis():
        """Check Redis connectivity."""
        try:
            import redis

            r = redis.Redis(host="localhost", port=6379, db=0)
            r.ping()
            return True
        except Exception as e:
            current_app.logger.error(f"Redis health check failed: {str(e)}")
            return False

    health_monitor.register_health_check("database", check_database)
    health_monitor.register_health_check("redis", check_redis)

    current_app.logger.info("Monitoring system initialized")

    return health_monitor 
