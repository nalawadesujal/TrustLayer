import os
import pickle
import numpy as np
import librosa
from app.ml.base import BaseDetector

class VoiceDetector(BaseDetector):
    def __init__(self):
        self.classifier_path = os.path.join('models_weights', 'voice', 'voice_classifier.pkl')
        self.classifier = None
        self.is_trained = False
        self.load_model()
        
    def load_model(self):
        """Attempts to load the Random Forest voice classifier."""
        if os.path.exists(self.classifier_path):
            try:
                with open(self.classifier_path, 'rb') as f:
                    self.classifier = pickle.load(f)
                self.is_trained = True
            except Exception as e:
                print(f"Warning: Failed to load voice classifier weights: {e}")
                self.is_trained = False
        else:
            print("Warning: Voice detector weights not found. Running in acoustic-variance fallback mode.")
            self.is_trained = False

    def preprocess(self, audio_path):
        """Loads the audio file and resamples it to 16kHz mono, trimming silence."""
        try:
            y, sr = librosa.load(audio_path, sr=16000, mono=True)
            y_trimmed, _ = librosa.effects.trim(y, top_db=25)
            return {
                'y': y_trimmed,
                'sr': sr
            }
        except Exception as e:
            raise ValueError(f"Could not read audio file: {str(e)}")

    def extract_features(self, preprocessed_data):
        """Extracts MFCCs, spectral roll-off, spectral centroid, and zero crossing rates."""
        y = preprocessed_data['y']
        sr = preprocessed_data['sr']
        
        if len(y) == 0:
            raise ValueError("Audio clip is silent or too short.")
            
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
        mfccs_mean = np.mean(mfccs, axis=1)
        mfccs_std = np.std(mfccs, axis=1)
        
        centroid = librosa.feature.spectral_centroid(y=y, sr=sr)
        centroid_mean = np.mean(centroid)
        centroid_std = np.std(centroid)
        
        rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr)
        rolloff_mean = np.mean(rolloff)
        rolloff_std = np.std(rolloff)
        
        zcr = librosa.feature.zero_crossing_rate(y)
        zcr_mean = np.mean(zcr)
        zcr_std = np.std(zcr)
        
        chroma = librosa.feature.chroma_stft(y=y, sr=sr)
        chroma_mean = np.mean(chroma)
        
        features = np.concatenate([
            mfccs_mean, mfccs_std,
            [centroid_mean, centroid_std],
            [rolloff_mean, rolloff_std],
            [zcr_mean, zcr_std],
            [chroma_mean]
        ])
        
        return features

    def predict(self, input_data) -> dict:
        """Evaluates audio sample for synthetic generation markers."""
        try:
            preprocessed = self.preprocess(input_data)
        except Exception as e:
            return {
                'verdict': 'human',
                'confidence': 0.0,
                'metrics': {'error': f'Audio loading failed: {str(e)}'}
            }
            
        try:
            feature_vector = self.extract_features(preprocessed)
        except Exception as e:
            return {
                'verdict': 'human',
                'confidence': 0.0,
                'metrics': {'error': f'Feature extraction failed: {str(e)}'}
            }
            
        mfcc_stds = feature_vector[13:26]
        avg_mfcc_variance = float(np.mean(mfcc_stds))
        
        metrics = {
            'spectral_centroid_hz': float(round(feature_vector[26], 2)),
            'spectral_rolloff_hz': float(round(feature_vector[28], 2)),
            'zero_crossing_rate': float(round(feature_vector[30], 4)),
            'avg_mfcc_variance': float(round(avg_mfcc_variance, 4))
        }
        
        if self.is_trained and self.classifier:
            try:
                feature_input = feature_vector.reshape(1, -1)
                prob = self.classifier.predict_proba(feature_input)[0][1]
                verdict = 'ai' if prob >= 0.5 else 'human'
                confidence = prob if verdict == 'ai' else (1.0 - prob)
                
                metrics['ml_mode'] = True
                return {
                    'verdict': verdict,
                    'confidence': float(round(confidence, 4)),
                    'metrics': metrics
                }
            except Exception as e:
                print(f"Voice ML prediction failed, falling back to acoustic variance heuristics: {e}")
                
        # Heuristic Acoustic Fallback
        baseline_variance = 12.0
        if avg_mfcc_variance < baseline_variance:
            verdict = 'ai'
            dist = baseline_variance - avg_mfcc_variance
            confidence = 0.5 + min(dist * 0.06, 0.45)
        else:
            verdict = 'human'
            dist = avg_mfcc_variance - baseline_variance
            confidence = 0.5 + min(dist * 0.04, 0.45)
            
        metrics['ml_mode'] = False
        metrics['fallback_reason'] = 'Weights not trained. Using acoustic variance heuristics.'
        
        return {
            'verdict': verdict,
            'confidence': float(round(confidence, 4)),
            'metrics': metrics
        }
