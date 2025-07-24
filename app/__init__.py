from flask import Flask
from flask_login import LoginManager
from config import Config
import mongoengine

db = mongoengine
login_manager = LoginManager()


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Initialize extensions
    # Temporarily disable MongoDB connection to get app running
    try:
        db.connect(host=app.config['MONGODB_SETTINGS']['host'])
    except Exception as e:
        print(f"MongoDB connection failed: {e}")
        # Continue without database for now
    
    login_manager.init_app(app)

    # Configure login manager
    login_manager.login_view = "auth.login"
    login_manager.login_message = "Please log in to access this page."

    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.tasks import tasks_bp
    from app.routes.main import main_bp
    from app.routes.api import api_bp
    from app.routes.swagger_api import api as swagger_api

    app.register_blueprint(auth_bp)
    app.register_blueprint(tasks_bp)
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp)

    # Initialize Swagger API
    swagger_api.init_app(app)

    return app
