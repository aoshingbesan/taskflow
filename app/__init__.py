from flask import Flask
from flask_login import LoginManager
from config import Config
import mongoengine

db = mongoengine
login_manager = LoginManager()


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Initialize monitoring and observability
    # from app.monitoring import init_monitoring
    # health_monitor = init_monitoring(app)

    # Initialize security features
    # from app.security import init_security
    # init_security(app)

    # Initialize monitoring dashboard
    # from app.dashboard_monitoring import init_monitoring_dashboard
    # init_monitoring_dashboard(app)

    # Initialize extensions
    login_manager.init_app(app)
    login_manager.login_view = "auth.login"

    # Register blueprints
    from app.routes import auth, tasks, main, api, swagger_api

    app.register_blueprint(auth.auth_bp)
    app.register_blueprint(tasks.tasks_bp)
    app.register_blueprint(main.main_bp)
    app.register_blueprint(api.api_bp)

    # Initialize Swagger API
    swagger_api.init_app(app)

    return app
