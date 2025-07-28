"""
Monitoring Dashboard for TaskFlow

This module provides a comprehensive monitoring dashboard with:
- Real-time application metrics
- Performance monitoring
- Security alerts
- User activity tracking
- System health monitoring
"""

import json
import time
from datetime import datetime, timedelta
from flask import Blueprint, render_template, jsonify, request, g
from flask_login import login_required, current_user
from app.monitoring import log_user_activity, log_api_usage

# Create monitoring dashboard blueprint
monitoring_bp = Blueprint('monitoring', __name__, url_prefix='/monitoring')

# In-memory storage for metrics (in production, use Redis or database)
_metrics_storage = {
    'requests': [],
    'errors': [],
    'security_events': [],
    'performance': [],
    'user_activity': []
}

def add_metric(metric_type, data):
    """Add a metric to storage."""
    timestamp = datetime.utcnow()
    metric = {
        'timestamp': timestamp.isoformat(),
        'type': metric_type,
        'data': data
    }
    
    _metrics_storage[metric_type].append(metric)
    
    # Keep only last 1000 metrics per type
    if len(_metrics_storage[metric_type]) > 1000:
        _metrics_storage[metric_type] = _metrics_storage[metric_type][-1000:]

@monitoring_bp.route('/dashboard')
@login_required
def monitoring_dashboard():
    """Main monitoring dashboard page."""
    log_user_activity(current_user.id, 'view_monitoring_dashboard')
    
    # Calculate metrics for the last 24 hours
    now = datetime.utcnow()
    yesterday = now - timedelta(days=1)
    
    # Filter metrics for last 24 hours
    recent_requests = [m for m in _metrics_storage['requests'] 
                      if datetime.fromisoformat(m['timestamp']) > yesterday]
    recent_errors = [m for m in _metrics_storage['errors'] 
                    if datetime.fromisoformat(m['timestamp']) > yesterday]
    recent_security = [m for m in _metrics_storage['security_events'] 
                      if datetime.fromisoformat(m['timestamp']) > yesterday]
    
    # Calculate statistics
    stats = {
        'total_requests': len(recent_requests),
        'total_errors': len(recent_errors),
        'security_events': len(recent_security),
        'error_rate': (len(recent_errors) / max(len(recent_requests), 1)) * 100,
        'avg_response_time': calculate_avg_response_time(recent_requests),
        'top_endpoints': get_top_endpoints(recent_requests),
        'recent_errors': recent_errors[-10:],  # Last 10 errors
        'recent_security_events': recent_security[-10:]  # Last 10 security events
    }
    
    return render_template('monitoring/dashboard.html', stats=stats)

@monitoring_bp.route('/api/metrics')
@login_required
def get_metrics():
    """API endpoint to get current metrics."""
    log_api_usage('/monitoring/api/metrics', 'GET', 200)
    
    # Get metrics for the last hour
    now = datetime.utcnow()
    hour_ago = now - timedelta(hours=1)
    
    recent_metrics = {}
    for metric_type, metrics in _metrics_storage.items():
        recent_metrics[metric_type] = [
            m for m in metrics 
            if datetime.fromisoformat(m['timestamp']) > hour_ago
        ]
    
    return jsonify({
        'timestamp': now.isoformat(),
        'metrics': recent_metrics,
        'summary': {
            'requests_per_minute': len(recent_metrics['requests']) / 60,
            'errors_per_minute': len(recent_metrics['errors']) / 60,
            'security_events_per_minute': len(recent_metrics['security_events']) / 60
        }
    })

@monitoring_bp.route('/api/alerts')
@login_required
def get_alerts():
    """Get current alerts and warnings."""
    log_api_usage('/monitoring/api/alerts', 'GET', 200)
    
    alerts = []
    now = datetime.utcnow()
    
    # Check for high error rate
    recent_requests = [m for m in _metrics_storage['requests'] 
                      if datetime.fromisoformat(m['timestamp']) > now - timedelta(minutes=5)]
    recent_errors = [m for m in _metrics_storage['errors'] 
                    if datetime.fromisoformat(m['timestamp']) > now - timedelta(minutes=5)]
    
    if recent_requests and len(recent_errors) / len(recent_requests) > 0.1:  # 10% error rate
        alerts.append({
            'type': 'error_rate_high',
            'severity': 'high',
            'message': f'High error rate detected: {(len(recent_errors) / len(recent_requests)) * 100:.1f}%',
            'timestamp': now.isoformat()
        })
    
    # Check for security events
    recent_security = [m for m in _metrics_storage['security_events'] 
                      if datetime.fromisoformat(m['timestamp']) > now - timedelta(minutes=5)]
    
    if recent_security:
        alerts.append({
            'type': 'security_events',
            'severity': 'medium',
            'message': f'{len(recent_security)} security events in the last 5 minutes',
            'timestamp': now.isoformat()
        })
    
    # Check for slow response times
    slow_requests = [m for m in recent_requests 
                    if m['data'].get('duration', 0) > 2.0]  # Over 2 seconds
    
    if slow_requests:
        alerts.append({
            'type': 'slow_responses',
            'severity': 'medium',
            'message': f'{len(slow_requests)} slow requests detected',
            'timestamp': now.isoformat()
        })
    
    return jsonify({
        'alerts': alerts,
        'total_alerts': len(alerts)
    })

def calculate_avg_response_time(requests):
    """Calculate average response time from request metrics."""
    if not requests:
        return 0
    
    total_time = sum(m['data'].get('duration', 0) for m in requests)
    return total_time / len(requests)

def get_top_endpoints(requests):
    """Get top endpoints by request count."""
    endpoint_counts = {}
    
    for request in requests:
        endpoint = request['data'].get('endpoint', 'unknown')
        endpoint_counts[endpoint] = endpoint_counts.get(endpoint, 0) + 1
    
    # Sort by count and return top 10
    sorted_endpoints = sorted(endpoint_counts.items(), key=lambda x: x[1], reverse=True)
    return sorted_endpoints[:10]

# Metrics collection functions
def record_request(endpoint, method, status_code, duration):
    """Record a request metric."""
    add_metric('requests', {
        'endpoint': endpoint,
        'method': method,
        'status_code': status_code,
        'duration': duration,
        'timestamp': datetime.utcnow().isoformat()
    })

def record_error(error_type, error_message, endpoint=None):
    """Record an error metric."""
    add_metric('errors', {
        'type': error_type,
        'message': error_message,
        'endpoint': endpoint,
        'timestamp': datetime.utcnow().isoformat()
    })

def record_security_event(event_type, details):
    """Record a security event."""
    add_metric('security_events', {
        'type': event_type,
        'details': details,
        'timestamp': datetime.utcnow().isoformat()
    })

def record_performance_metric(metric_name, value):
    """Record a performance metric."""
    add_metric('performance', {
        'name': metric_name,
        'value': value,
        'timestamp': datetime.utcnow().isoformat()
    })

# Health check endpoint for monitoring
@monitoring_bp.route('/health')
def monitoring_health():
    """Health check endpoint for monitoring system."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'metrics_count': {
            'requests': len(_metrics_storage['requests']),
            'errors': len(_metrics_storage['errors']),
            'security_events': len(_metrics_storage['security_events']),
            'performance': len(_metrics_storage['performance']),
            'user_activity': len(_metrics_storage['user_activity'])
        }
    })

# Initialize monitoring dashboard
def init_monitoring_dashboard(app):
    """Initialize the monitoring dashboard."""
    app.register_blueprint(monitoring_bp)
    
    # Register request logging
    @app.before_request
    def before_request_monitoring():
        g.request_start_time = time.time()
    
    @app.after_request
    def after_request_monitoring(response):
        if hasattr(g, "request_start_time"):
            duration = time.time() - g.request_start_time
            record_request(request.endpoint or "unknown", request.method, response.status_code, duration)
        return response
    
    # Register error logging
    @app.errorhandler(Exception)
    def handle_exception(e):
        record_error(type(e).__name__, str(e), request.endpoint if request else None)
        return jsonify({"error": "Internal server error"}), 500
    
    app.logger.info("Monitoring dashboard initialized") 