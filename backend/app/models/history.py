import json
from datetime import datetime
from app import db

class Detection(db.Model):
    __tablename__ = 'detections'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    modality = db.Column(db.String(10), nullable=False)  # 'text', 'image', 'voice'
    input_summary = db.Column(db.String(255), nullable=False)  # Snippet or filename
    confidence = db.Column(db.Float, nullable=False)  # Probability AI-generated
    verdict = db.Column(db.String(10), nullable=False)  # 'ai' or 'human'
    metadata_json = db.Column(db.Text, name='metadata', nullable=True)  # Stores diagnostic metrics
    created_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    
    def set_metadata(self, data_dict):
        """Serializes dictionary to JSON string."""
        if data_dict:
            self.metadata_json = json.dumps(data_dict)
        else:
            self.metadata_json = None
            
    def get_metadata(self):
        """Deserializes JSON string to dictionary."""
        if self.metadata_json:
            try:
                return json.loads(self.metadata_json)
            except ValueError:
                return {}
        return {}
        
    def to_dict(self):
        """Serializes entry for API consumption."""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'modality': self.modality,
            'input_summary': self.input_summary,
            'confidence': self.confidence,
            'verdict': self.verdict,
            'metadata': self.get_metadata(),
            'created_at': self.created_at.isoformat()
        }
