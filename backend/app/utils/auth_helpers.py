import jwt
from functools import wraps
from flask import request, jsonify, current_app
from app.models.user import User

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Check authorization header
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                # Expecting Format: Bearer <JWT Token>
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'message': 'Token format is invalid! Use Bearer <token>'}), 401
                
        if not token:
            return jsonify({'message': 'Authentication token is missing!'}), 401
            
        try:
            # Decode token using app's SECRET_KEY
            payload = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.get(payload['user_id'])
            if not current_user:
                return jsonify({'message': 'Invalid user account!'}), 401
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token has expired! Please log in again.'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Token is invalid!'}), 401
            
        # Call the actual route handler with current_user
        return f(current_user, *args, **kwargs)
        
    return decorated
