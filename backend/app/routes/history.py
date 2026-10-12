from flask import Blueprint, jsonify
from app import db
from app.models.history import Detection
from app.utils.auth_helpers import token_required

history_bp = Blueprint('history', __name__)

@history_bp.route('', methods=['GET'])
@token_required
def get_history(current_user):
    """Fetches list of previous detections for current user, sorted by date."""
    try:
        detections = Detection.query.filter_by(user_id=current_user.id).order_by(Detection.created_at.desc()).all()
        return jsonify([d.to_dict() for d in detections]), 200
    except Exception as e:
        return jsonify({'message': 'Failed to retrieve history logs.', 'error': str(e)}), 500

@history_bp.route('/<int:detection_id>', methods=['DELETE'])
@token_required
def delete_history_item(current_user, detection_id):
    """Deletes specific historical record owned by current user."""
    try:
        detection = Detection.query.filter_by(id=detection_id, user_id=current_user.id).first()
        if not detection:
            return jsonify({'message': 'Detection record not found or access denied.'}), 404
            
        db.session.delete(detection)
        db.session.commit()
        return jsonify({'message': 'Detection record deleted successfully.'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': 'Failed to delete record.', 'error': str(e)}), 500
