import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from app import db
from app.models.user import User

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or not data.get('username') or not data.get('email') or not data.get('password'):
        return jsonify({'message': 'Missing registration parameters!'}), 400
        
    username = data['username'].strip()
    email = data['email'].strip().lower()
    password = data['password']
    
    # Check if user already exists
    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'Username is already taken!'}), 409
        
    if User.query.filter_by(email=email).first():
        return jsonify({'message': 'Email is already registered!'}), 409
        
    # Register user
    try:
        new_user = User(username=username, email=email)
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.commit()
        return jsonify({'message': 'User registered successfully!'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Internal Server Error', 'error': str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'message': 'Missing email or password!'}), 400
        
    email = data['email'].strip().lower()
    password = data['password']
    
    # Fetch user
    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        return jsonify({'message': 'Invalid email or password!'}), 401
        
    # Generate JWT Token (valid for 24 hours)
    token = jwt.encode({
        'user_id': user.id,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, current_app.config['SECRET_KEY'], algorithm='HS256')
    
    return jsonify({
        'token': token,
        'user': user.to_dict()
    }), 200
