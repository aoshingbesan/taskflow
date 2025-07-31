import os
import logging
from flask import Flask
from flask_login import LoginManager
import mongoengine

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_app():
    app = Flask(__name__)

    # Configuration
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "your-super-secret-key-change-this")
    app.config["MONGODB_URI"] = os.getenv("MONGODB_URI")

    # Initialize extensions
    login_manager = LoginManager()
    login_manager.init_app(app)
    login_manager.login_view = "auth.login"

    # MongoDB connection (optional)
    if app.config["MONGODB_URI"]:
        try:
            mongoengine.connect(
                host=app.config["MONGODB_URI"],
                serverSelectionTimeoutMS=30000,  # 30 seconds instead of 5
                connectTimeoutMS=30000,  # 30 seconds instead of 5
                socketTimeoutMS=30000,  # 30 seconds instead of 5
            )
            logger.info("MongoDB connection established")
        except Exception as e:
            logger.error(f"MongoDB connection failed: {e}")
            logger.info("MongoDB connection skipped")
    else:
        logger.info("MongoDB connection skipped - no URI provided")

    # Import and register blueprints
    try:
        from app.routes.auth import auth_bp
        from app.routes.main import main_bp
        from app.routes.tasks import tasks_bp
        from app.routes.api import api_bp

        app.register_blueprint(auth_bp)
        app.register_blueprint(main_bp)
        app.register_blueprint(tasks_bp)
        app.register_blueprint(api_bp)
        logger.info("All blueprints registered successfully")
    except Exception as e:
        logger.error(f"Error registering blueprints: {e}")

    # Initialize Swagger API
    try:
        from app.routes.swagger_api import init_app as init_swagger

        init_swagger(app)
        logger.info("Swagger API initialized")
    except Exception as e:
        logger.error(f"Error initializing Swagger: {e}")

    # User loader for Flask-Login
    try:
        from app.models import User
        from bson import ObjectId

        @login_manager.user_loader
        def load_user(user_id):
            try:
                return User.objects(id=ObjectId(user_id)).first()
            except:
                return None

        logger.info("User loader configured")
    except Exception as e:
        logger.error(f"Error configuring user loader: {e}")

    logger.info("TaskFlow application initialized successfully")
    return app


# Create the application instance
app = create_app()
db = mongoengine

if __name__ == "__main__":
    app.run(debug=True)
