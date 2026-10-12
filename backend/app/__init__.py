import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_cors import CORS

db = SQLAlchemy()
bcrypt = Bcrypt()

def create_app():
    app = Flask(__name__, instance_relative_config=True)
    
    # Load configuration
    from app.config import Config
    app.config.from_object(Config)
    
    # Ensure the instance and upload folders exist
    os.makedirs(app.instance_path, exist_ok=True)
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    
    # Initialize extensions
    db.init_app(app)
    bcrypt.init_app(app)
    CORS(app)  # Enable Cross-Origin Resource Sharing for Flutter client
    
    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.detect import detect_bp
    from app.routes.history import history_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(detect_bp, url_prefix='/api/detect')
    app.register_blueprint(history_bp, url_prefix='/api/history')
    
    # Create database tables
    with app.app_context():
        from app import models  # Register models without shadowing local 'app'
        db.create_all()
        
    return app
