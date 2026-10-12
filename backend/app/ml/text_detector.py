import os
import pickle
import numpy as np
import nltk
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.corpus import stopwords
from app.ml.base import BaseDetector

# Dynamically download required NLTK resources
try:
    nltk.data.find('tokenizers/punkt')
except LookupError:
    nltk.download('punkt', quiet=True)
try:
    nltk.data.find('corpora/stopwords')
except LookupError:
    nltk.download('stopwords', quiet=True)

class TextDetector(BaseDetector):
    def __init__(self):
        self.vectorizer_path = os.path.join('models_weights', 'text', 'tfidf_vectorizer.pkl')
        self.classifier_path = os.path.join('models_weights', 'text', 'text_classifier.pkl')
        
        self.vectorizer = None
        self.classifier = None
        self.is_trained = False
        self.load_model()
        
    def load_model(self):
        """Attempts to load the TF-IDF vectorizer and classifier weights."""
        if os.path.exists(self.vectorizer_path) and os.path.exists(self.classifier_path):
            try:
                with open(self.vectorizer_path, 'rb') as f:
                    self.vectorizer = pickle.load(f)
                with open(self.classifier_path, 'rb') as f:
                    self.classifier = pickle.load(f)
                self.is_trained = True
            except Exception as e:
                print(f"Warning: Failed to load text classifier weights: {e}")
                self.is_trained = False
        else:
            print("Warning: Text detector weights not found. Running in rule-based fallback mode.")
            self.is_trained = False

    def preprocess(self, text):
        """Tokenizes text and calculates basic stylometric indices."""
        sentences = sent_tokenize(text)
        words = word_tokenize(text.lower())
        
        # Remove stopwords and non-alphabetic tokens for vectorization
        stop_words = set(stopwords.words('english'))
        cleaned_words = [w for w in words if w.isalpha() and w not in stop_words]
        
        # Calculate stylometric features
        avg_sent_len = len(words) / max(len(sentences), 1)
        avg_word_len = np.mean([len(w) for w in words]) if words else 0
        ttr = len(set(words)) / max(len(words), 1)  # Type-Token Ratio (lexical diversity)
        
        return {
            'cleaned_text': " ".join(cleaned_words),
            'metrics': {
                'avg_sentence_length': float(round(avg_sent_len, 2)),
                'avg_word_length': float(round(avg_word_len, 2)),
                'lexical_diversity': float(round(ttr, 2))
            }
        }

    def extract_features(self, preprocessed_data):
        """Extracts TF-IDF features from the cleaned text."""
        if not self.is_trained or not self.vectorizer:
            return None
        return self.vectorizer.transform([preprocessed_data['cleaned_text']])

    def predict(self, input_data) -> dict:
        if not input_data or not input_data.strip():
            return {
                'verdict': 'human',
                'confidence': 0.0,
                'metrics': {'error': 'Empty input text'}
            }
            
        preprocessed = self.preprocess(input_data)
        metrics = preprocessed['metrics']
        
        if self.is_trained and self.classifier and self.vectorizer:
            try:
                features = self.extract_features(preprocessed)
                prob = self.classifier.predict_proba(features)[0][1]  # Prob of index 1 (AI class)
                verdict = 'ai' if prob >= 0.5 else 'human'
                confidence = prob if verdict == 'ai' else (1.0 - prob)
                
                metrics['ml_mode'] = True
                return {
                    'verdict': verdict,
                    'confidence': float(round(confidence, 4)),
                    'metrics': metrics
                }
            except Exception as e:
                print(f"Prediction failed, falling back to heuristics: {e}")
                
        # Heuristic/Rule-based Fallback
        ttr = metrics['lexical_diversity']
        
        if ttr < 0.50:
            verdict = 'ai'
            confidence = 0.5 + (0.50 - ttr)
        else:
            verdict = 'human'
            confidence = 0.5 + min((ttr - 0.50), 0.5)
            
        metrics['ml_mode'] = False
        metrics['fallback_reason'] = 'Weights not trained. Using Lexical Diversity fallback.'
        
        return {
            'verdict': verdict,
            'confidence': float(round(min(confidence, 0.99), 4)),
            'metrics': metrics
        }
