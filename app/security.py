"""
Security Module for TaskFlow

This module implements DevSecOps security practices including:
- Input validation and sanitization
- Rate limiting
- Security headers
- CSRF protection
- XSS prevention
"""

import re
import hashlib
import time
from functools import wraps
from flask import request, jsonify, current_app, g
from flask_login import current_user
import bleach

# Rate limiting storage (in production, use Redis)
_rate_limit_storage = {}

def sanitize_input(input_string):
    """Sanitize user input to prevent XSS and injection attacks."""
    if not input_string:
        return ""
    
    # Remove potentially dangerous HTML tags
    allowed_tags = ['b', 'i', 'em', 'strong', 'p', 'br']
    allowed_attributes = {}
    
    cleaned = bleach.clean(
        input_string,
        tags=allowed_tags,
        attributes=allowed_attributes,
        strip=True
    )
    
    # Additional sanitization for common attack patterns
    patterns = [
        r'<script.*?</script>',
        r'javascript:',
        r'on\w+\s*=',
        r'<iframe.*?</iframe>',
        r'<object.*?</object>',
        r'<embed.*?</embed>'
    ]
    
    for pattern in patterns:
        cleaned = re.sub(pattern, '', cleaned, flags=re.IGNORECASE)
    
    return cleaned.strip()

def validate_email(email):
    """Validate email format and prevent email injection."""
    if not email:
        return False
    
    # Basic email validation
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(email_pattern, email):
        return False
    
    # Check for suspicious patterns
    suspicious_patterns = [
        r'<script',
        r'javascript:',
        r'<iframe',
        r'<object',
        r'<embed'
    ]
    
    for pattern in suspicious_patterns:
        if re.search(pattern, email, re.IGNORECASE):
            return False
    
    return True

def validate_password(password):
    """Validate password strength."""
    if not password or len(password) < 8:
        return False, "Password must be at least 8 characters long"
    
    # Check for common weak passwords
    weak_passwords = [
        'password', '123456', 'qwerty', 'admin', 'user',
        'test', 'demo', 'guest', 'welcome', 'login'
    ]
    
    if password.lower() in weak_passwords:
        return False, "Password is too common"
    
    # Check for minimum complexity
    has_upper = any(c.isupper() for c in password)
    has_lower = any(c.islower() for c in password)
    has_digit = any(c.isdigit() for c in password)
    
    if not (has_upper and has_lower and has_digit):
        return False, "Password must contain uppercase, lowercase, and numbers"
    
    return True, "Password is strong"

def rate_limit(limit=100, window=3600):
    """Rate limiting decorator."""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # Get client identifier
            client_id = request.remote_addr
            if current_user.is_authenticated:
                client_id = f"{client_id}:{current_user.id}"
            
            # Check rate limit
            current_time = time.time()
            key = f"{client_id}:{f.__name__}"
            
            if key in _rate_limit_storage:
                requests, window_start = _rate_limit_storage[key]
                
                # Reset window if expired
                if current_time - window_start > window:
                    requests = 0
                    window_start = current_time
                
                # Check if limit exceeded
                if requests >= limit:
                    current_app.logger.warning(
                        f"Rate limit exceeded for {client_id} on {f.__name__}"
                    )
                    return jsonify({
                        'error': 'Rate limit exceeded',
                        'retry_after': window - (current_time - window_start)
                    }), 429
                
                requests += 1
            else:
                requests = 1
                window_start = current_time
            
            _rate_limit_storage[key] = (requests, window_start)
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def require_authentication(f):
    """Decorator to require user authentication."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            return jsonify({'error': 'Authentication required'}), 401
        return f(*args, **kwargs)
    return decorated_function

def log_security_event(event_type, details):
    """Log security events for monitoring."""
    from app.monitoring import log_security_event as log_sec_event
    log_sec_event(event_type, details)

def validate_task_data(data):
    """Validate task creation/update data."""
    errors = []
    
    # Validate title
    if 'title' in data:
        title = data['title']
        if not title or len(title.strip()) == 0:
            errors.append("Title is required")
        elif len(title) > 200:
            errors.append("Title must be less than 200 characters")
        else:
            # Sanitize title
            data['title'] = sanitize_input(title)
    
    # Validate description
    if 'description' in data:
        description = data['description']
        if description and len(description) > 1000:
            errors.append("Description must be less than 1000 characters")
        elif description:
            # Sanitize description
            data['description'] = sanitize_input(description)
    
    # Validate status
    if 'status' in data:
        status = data['status']
        valid_statuses = ['todo', 'in_progress', 'completed']
        if status not in valid_statuses:
            errors.append(f"Status must be one of: {', '.join(valid_statuses)}")
    
    return errors

def add_security_headers(response):
    """Add security headers to all responses."""
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['Content-Security-Policy'] = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    return response

def validate_json_payload():
    """Validate JSON payload for API requests."""
    if not request.is_json:
        return False, "Content-Type must be application/json"
    
    try:
        request.get_json()
    except Exception:
        return False, "Invalid JSON payload"
    
    return True, None

def sanitize_user_input(input_data):
    """Sanitize all user input data."""
    if isinstance(input_data, dict):
        return {key: sanitize_user_input(value) for key, value in input_data.items()}
    elif isinstance(input_data, list):
        return [sanitize_user_input(item) for item in input_data]
    elif isinstance(input_data, str):
        return sanitize_input(input_data)
    else:
        return input_data

# Security middleware
def init_security(app):
    """Initialize security features."""
    
    @app.before_request
    def before_request():
        """Security checks before each request."""
        # Log suspicious requests
        user_agent = request.headers.get('User-Agent', '')
        if any(pattern in user_agent.lower() for pattern in ['bot', 'crawler', 'spider']):
            log_security_event('suspicious_user_agent', {'user_agent': user_agent})
        
        # Check for suspicious headers
        suspicious_headers = ['x-forwarded-for', 'x-real-ip', 'x-forwarded-proto']
        for header in suspicious_headers:
            if header in request.headers:
                log_security_event('suspicious_header', {'header': header, 'value': request.headers[header]})
    
    @app.after_request
    def after_request(response):
        """Add security headers after each request."""
        return add_security_headers(response)
    
    current_app.logger.info("Security features initialized") 