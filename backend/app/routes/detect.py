import os
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
from app import db
from app.models.history import Detection
from app.utils.auth_helpers import token_required
from app.utils.file_validators import allowed_file
from app.ml.text_detector import TextDetector
from app.ml.image_detector import ImageDetector
from app.ml.voice_detector import VoiceDetector

detect_bp = Blueprint('detect', __name__)

# Instantiate detectors (lazy loaded / cached in memory)
text_detector = TextDetector()
image_detector = ImageDetector()
voice_detector = VoiceDetector()

@detect_bp.route('/text', methods=['POST'])
@token_required
def detect_text(current_user):
    data = request.get_json()
    if not data or not data.get('text'):
        return jsonify({'message': 'Missing text content for analysis.'}), 400
        
    text = data['text'].strip()
    if len(text) < 10:
        return jsonify({'message': 'Text is too short. Minimum 10 characters required.'}), 400
        
    try:
        # Run ML model prediction
        result = text_detector.predict(text)
        
        # Save to database history
        summary = text[:50] + ("..." if len(text) > 50 else "")
        detection = Detection(
            user_id=current_user.id,
            modality='text',
            input_summary=summary,
            confidence=result['confidence'],
            verdict=result['verdict']
        )
        detection.set_metadata(result['metrics'])
        
        db.session.add(detection)
        db.session.commit()
        
        return jsonify(detection.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Failed to process text detection.', 'error': str(e)}), 500


@detect_bp.route('/image', methods=['POST'])
@token_required
def detect_image(current_user):
    if 'image' not in request.files:
        return jsonify({'message': 'No image file uploaded in field "image".'}), 400
        
    file = request.files['image']
    if file.filename == '':
        return jsonify({'message': 'Empty file selected.'}), 400
        
    if not allowed_file(file.filename, 'image'):
        return jsonify({'message': 'Unsupported file format. Use PNG, JPG, or JPEG.'}), 415
        
    try:
        # Secure filename and save temporarily
        filename = secure_filename(file.filename)
        temp_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        file.save(temp_path)
        
        # Run image detector pipeline
        result = image_detector.predict(temp_path)
        
        # Check if processing error occurred
        if 'error' in result['metrics']:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return jsonify({'message': result['metrics']['error']}), 400
            
        # Save to database
        detection = Detection(
            user_id=current_user.id,
            modality='image',
            input_summary=filename,
            confidence=result['confidence'],
            verdict=result['verdict']
        )
        detection.set_metadata(result['metrics'])
        
        db.session.add(detection)
        db.session.commit()
        
        # Clean up uploaded file
        if os.path.exists(temp_path):
            os.remove(temp_path)
            
        return jsonify(detection.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        # Ensure cleanup in case of failures
        if 'temp_path' in locals() and os.path.exists(temp_path):
            os.remove(temp_path)
        return jsonify({'message': 'Failed to process image detection.', 'error': str(e)}), 500


@detect_bp.route('/voice', methods=['POST'])
@token_required
def detect_voice(current_user):
    if 'voice' not in request.files:
        return jsonify({'message': 'No audio file uploaded in field "voice".'}), 400
        
    file = request.files['voice']
    if file.filename == '':
        return jsonify({'message': 'Empty file selected.'}), 400
        
    if not allowed_file(file.filename, 'voice'):
        return jsonify({'message': 'Unsupported file format. Use WAV, MP3, OGG, or M4A.'}), 415
        
    try:
        # Secure filename and save temporarily
        filename = secure_filename(file.filename)
        temp_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        file.save(temp_path)
        
        # Run Librosa MFCC pipeline
        result = voice_detector.predict(temp_path)
        
        # Check if processing error occurred
        if 'error' in result['metrics']:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return jsonify({'message': result['metrics']['error']}), 400
            
        # Save to database
        detection = Detection(
            user_id=current_user.id,
            modality='voice',
            input_summary=filename,
            confidence=result['confidence'],
            verdict=result['verdict']
        )
        detection.set_metadata(result['metrics'])
        
        db.session.add(detection)
        db.session.commit()
        
        # Clean up uploaded file
        if os.path.exists(temp_path):
            os.remove(temp_path)
            
        return jsonify(detection.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        # Ensure cleanup in case of failures
        if 'temp_path' in locals() and os.path.exists(temp_path):
            os.remove(temp_path)
        return jsonify({'message': 'Failed to process voice detection.', 'error': str(e)}), 500
