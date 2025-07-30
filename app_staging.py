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

    # MongoDB connection
    if app.config["MONGODB_URI"]:
        try:
            mongoengine.connect(
                host=app.config["MONGODB_URI"], serverSelectionTimeoutMS=5000, connectTimeoutMS=5000, socketTimeoutMS=5000
            )
            logger.info("MongoDB connection established")
        except Exception as e:
            logger.error(f"MongoDB connection failed: {e}")
            logger.info("MongoDB connection skipped")
    else:
        logger.info("MongoDB connection skipped - no URI provided")

    # Import and register blueprints
    from app.routes.auth import auth_bp
    from app.routes.main import main_bp
    from app.routes.tasks import tasks_bp
    from app.routes.api import api_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(main_bp)
    app.register_blueprint(tasks_bp)
    app.register_blueprint(api_bp)

    # Initialize Swagger API
    from app.routes.swagger_api import init_app as init_swagger
    init_swagger(app)

    # User loader for Flask-Login
    from app.models import User
    from bson import ObjectId

    @login_manager.user_loader
    def load_user(user_id):
        try:
            return User.objects(id=ObjectId(user_id)).first()
        except:
            return None

    logger.info("TaskFlow staging application initialized successfully")
    return app

# Create the application instance
app = create_app()

if __name__ == "__main__":
    app.run(debug=True) 