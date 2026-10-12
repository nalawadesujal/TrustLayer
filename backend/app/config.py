import os

class Config:
    # Flask Settings
    SECRET_KEY = os.environ.get('SECRET_KEY', 'trustlayer_super_secret_key_12345')
    
    # Database Settings
    BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL', 
        f'sqlite:///{os.path.join(BASE_DIR, "instance", "trustlayer.db")}'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Upload Settings
    UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16 MB max upload size
    ALLOWED_EXTENSIONS = {
        'image': {'png', 'jpg', 'jpeg'},
        'voice': {'wav', 'mp3', 'ogg', 'm4a'}
    }
