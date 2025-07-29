from flask import Flask
from flask_login import LoginManager
from config import Config
import mongoengine
import os
import logging

db = mongoengine
login_manager = LoginManager()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


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

    # Initialize MongoDB only if URI is provided
    mongodb_uri = os.environ.get("MONGODB_URI")
    if mongodb_uri and mongodb_uri != "mongodb://localhost:27017/taskflow":
        try:
            # Set connection timeout and retry settings
            mongoengine.connect(
                host=mongodb_uri,
                serverSelectionTimeoutMS=5000,  # 5 second timeout
                connectTimeoutMS=5000,
                socketTimeoutMS=5000
            )
            logger.info("MongoDB connected successfully")
            app.logger.info("MongoDB connected successfully")
        except Exception as e:
            logger.warning(f"MongoDB connection failed: {e}")
            app.logger.warning(f"MongoDB connection failed: {e}")
            # Continue without MongoDB - app will work with in-memory storage
    else:
        logger.info("MongoDB connection skipped - using in-memory storage")
        app.logger.info("MongoDB connection skipped - using in-memory storage")

    # Register blueprints
    try:
        from app.routes import auth, tasks, main, api, swagger_api

        app.register_blueprint(auth.auth_bp)
        app.register_blueprint(tasks.tasks_bp)
        app.register_blueprint(main.main_bp)
        app.register_blueprint(api.api_bp)

        # Initialize Swagger API
        swagger_api.init_app(app)
        
        logger.info("All blueprints registered successfully")
        app.logger.info("All blueprints registered successfully")
    except Exception as e:
        logger.error(f"Error registering blueprints: {e}")
        app.logger.error(f"Error registering blueprints: {e}")

    return app
