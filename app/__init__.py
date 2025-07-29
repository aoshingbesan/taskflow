from flask import Flask
from flask_login import LoginManager
from config import Config
import os
import logging

login_manager = LoginManager()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Initialize extensions
    login_manager.init_app(app)
    login_manager.login_view = "auth.login"

    # Skip MongoDB for now to get basic app working
    logger.info("Starting TaskFlow application without MongoDB")
    app.logger.info("Starting TaskFlow application without MongoDB")

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
