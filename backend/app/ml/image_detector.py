import os
import pickle
import cv2
import numpy as np
from app.ml.base import BaseDetector

IMAGE_SIZE = (256, 256)
CONFIDENCE_THRESHOLD = 0.95


class ImageDetector(BaseDetector):
    def __init__(self):
        self.classifier_path = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '..', '..', 'models_weights', 'image', 'image_classifier.pkl')
        )
        self.classifier = None
        self.model_name = None
        self.is_trained = False
        self.load_model()

    def load_model(self):
        """Attempts to load the image classifier."""
        if os.path.exists(self.classifier_path):
            try:
                with open(self.classifier_path, 'rb') as f:
                    saved_model = pickle.load(f)
                if isinstance(saved_model, dict) and 'model' in saved_model:
                    self.classifier = saved_model['model']
                    self.model_name = saved_model.get('model_name')
                else:
                    self.classifier = saved_model
                    self.model_name = type(saved_model).__name__
                self.is_trained = True
            except Exception as e:
                print(f"Warning: Failed to load image classifier weights: {e}")
                self.is_trained = False
        else:
            print("Warning: Image detector weights not found. Train the image model before detection.")
            self.is_trained = False

    def preprocess(self, image_path):
        """Reads, resizes, and converts images for feature extraction."""
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Could not load image file from path: {image_path}")

        img_resized = cv2.resize(img, IMAGE_SIZE, interpolation=cv2.INTER_AREA)
        gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)

        return {
            'bgr': img_resized,
            'gray': gray
        }

    def extract_features(self, preprocessed_data):
        """Extracts handcrafted OpenCV features used during training."""
        bgr = preprocessed_data['bgr']
        gray = preprocessed_data['gray']
        rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)

        color_histograms = []
        for channel_index in range(3):
            hist = cv2.calcHist([rgb], [channel_index], None, [32], [0, 256])
            hist = cv2.normalize(hist, hist).flatten()
            color_histograms.append(hist)

        edges = cv2.Canny(gray, 100, 200)
        edge_density = float(np.count_nonzero(edges) / edges.size)

        gray_float = gray.astype(np.float32)
        pixel_variance = float(np.var(gray_float))
        sharpness_score = float(cv2.Laplacian(gray, cv2.CV_64F).var())

        sobel_x = cv2.Sobel(gray_float, cv2.CV_32F, 1, 0, ksize=3)
        sobel_y = cv2.Sobel(gray_float, cv2.CV_32F, 0, 1, ksize=3)
        gradient_magnitude = cv2.magnitude(sobel_x, sobel_y)
        local_mean = cv2.blur(gray_float, (7, 7))
        local_contrast = np.abs(gray_float - local_mean)

        gray_hist = cv2.calcHist([gray], [0], None, [64], [0, 256]).flatten()
        gray_probability = gray_hist / max(float(gray_hist.sum()), 1.0)
        gray_probability = gray_probability[gray_probability > 0]
        entropy = float(-np.sum(gray_probability * np.log2(gray_probability)))

        texture_stats = np.array([
            edge_density,
            float(np.mean(gray_float)),
            float(np.std(gray_float)),
            pixel_variance,
            sharpness_score,
            entropy,
            float(np.mean(gradient_magnitude)),
            float(np.std(gradient_magnitude)),
            float(np.mean(local_contrast)),
            float(np.std(local_contrast)),
        ], dtype=np.float32)

        color_stats = []
        for channel_index in range(3):
            channel = rgb[:, :, channel_index]
            color_stats.extend([
                float(np.mean(channel)),
                float(np.std(channel)),
                float(np.var(channel)),
            ])

        return np.concatenate([
            *color_histograms,
            np.array(color_stats, dtype=np.float32),
            texture_stats,
        ])

    def predict(self, input_data) -> dict:
        """Processes file and determines if image is AI generated."""
        try:
            preprocessed = self.preprocess(input_data)
        except Exception as e:
            return {
                'verdict': 'Uncertain',
                'confidence': 0.0,
                'metrics': {'error': f'Image loading failed: {str(e)}'}
            }

        if not self.is_trained or not self.classifier:
            return {
                'verdict': 'Uncertain',
                'confidence': 0.0,
                'metrics': {'error': 'Image classifier weights not found. Train the image model first.'}
            }

        feature_vector = self.extract_features(preprocessed)

        gray = preprocessed['gray']
        edges = cv2.Canny(gray, 100, 200)
        edge_density = np.count_nonzero(edges) / edges.size
        laplacian_variance = cv2.Laplacian(gray, cv2.CV_64F).var()

        metrics = {
            'brightness_mean': float(round(np.mean(gray), 2)),
            'brightness_std': float(round(np.std(gray), 2)),
            'edge_density': float(round(edge_density, 4)),
            'laplacian_variance': float(round(laplacian_variance, 2)),
            'model_name': self.model_name,
            'ml_mode': True,
        }

        try:
            feature_input = feature_vector.reshape(1, -1)
            probabilities = self.classifier.predict_proba(feature_input)[0]
            predicted_label = int(np.argmax(probabilities))
            confidence = float(probabilities[predicted_label])
            verdict = 'ai' if predicted_label == 1 else 'real'

            if confidence < CONFIDENCE_THRESHOLD:
                verdict = 'Uncertain'

            metrics['ai_probability'] = float(round(probabilities[1], 4))
            metrics['real_probability'] = float(round(probabilities[0], 4))
            metrics['confidence_threshold'] = CONFIDENCE_THRESHOLD

            return {
                'verdict': verdict,
                'confidence': float(round(confidence, 4)),
                'metrics': metrics
            }
        except Exception as e:
            return {
                'verdict': 'Uncertain',
                'confidence': 0.0,
                'metrics': {'error': f'Image ML prediction failed: {str(e)}'}
            }
