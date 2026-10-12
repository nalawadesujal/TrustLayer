import cv2
import numpy as np
from app.ml.base import BaseDetector

HF_MODEL_ID = "prithivMLmods/deepfake-detector-model-v1"
CONFIDENCE_THRESHOLD = 0.85


class HuggingFaceImageDetector(BaseDetector):
    def __init__(self):
        self.model = None
        self.model_name = HF_MODEL_ID
        self.is_trained = False
        self.load_error = None
        self.load_model()

    def load_model(self):
        """Loads the Hugging Face image classifier once on CPU."""
        if self.model is not None:
            return True

        try:
            from transformers import pipeline

            self.model = pipeline(
                "image-classification",
                model=HF_MODEL_ID,
                device=-1,
                top_k=None,
            )
            self.is_trained = True
            self.load_error = None
            return True
        except Exception as e:
            self.is_trained = False
            self.load_error = str(e)
            print(f"Warning: Failed to load Hugging Face image detector: {e}")
            return False

    def preprocess(self, image_path):
        """Reads image with OpenCV for validation and lightweight metrics."""
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Could not load image file from path: {image_path}")

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        return {"gray": gray}

    def _build_metrics(self, preprocessed_data):
        gray = preprocessed_data["gray"]
        edges = cv2.Canny(gray, 100, 200)
        edge_density = np.count_nonzero(edges) / edges.size
        laplacian_variance = cv2.Laplacian(gray, cv2.CV_64F).var()

        return {
            "brightness_mean": float(round(np.mean(gray), 2)),
            "brightness_std": float(round(np.std(gray), 2)),
            "edge_density": float(round(edge_density, 4)),
            "laplacian_variance": float(round(laplacian_variance, 2)),
            "model_name": self.model_name,
            "ml_mode": True,
            "provider": "huggingface",
            "confidence_threshold": CONFIDENCE_THRESHOLD,
        }

    def extract_features(self, preprocessed_data):
        """Hugging Face pipeline handles model-specific feature extraction."""
        return preprocessed_data

    def _normalize_prediction(self, predictions):
        fake_score = None
        real_score = None

        for item in predictions:
            label = item.get("label", "").strip().lower()
            score = float(item.get("score", 0.0))

            if label in {"fake", "label_0", "class_0", "0"}:
                fake_score = score
            elif label in {"real", "label_1", "class_1", "1"}:
                real_score = score

        if fake_score is None or real_score is None:
            raise ValueError(f"Unexpected model labels: {predictions}")

        if fake_score >= real_score:
            return "ai", fake_score, fake_score, real_score
        return "real", real_score, fake_score, real_score

    def _log_raw_predictions(self, predictions):
        print(f"Raw {HF_MODEL_ID} predictions:")
        for item in predictions:
            print(f"label={item.get('label')} score={item.get('score')}")

    def predict(self, input_data) -> dict:
        """Processes file and determines if image is AI generated."""
        try:
            preprocessed = self.preprocess(input_data)
        except Exception as e:
            return {
                "verdict": "Uncertain",
                "confidence": 0.0,
                "metrics": {"error": f"Image loading failed: {str(e)}"},
            }

        if not self.is_trained or self.model is None:
            return {
                "verdict": "Uncertain",
                "confidence": 0.0,
                "metrics": {
                    "error": (
                        "Hugging Face image detector could not be loaded. "
                        f"Install dependencies and check model access: {self.load_error}"
                    )
                },
            }

        metrics = self._build_metrics(preprocessed)

        try:
            predictions = self.model(input_data)
            self._log_raw_predictions(predictions)
            verdict, confidence, fake_score, real_score = self._normalize_prediction(predictions)

            if confidence < CONFIDENCE_THRESHOLD:
                verdict = "Uncertain"

            if fake_score is not None:
                metrics["ai_probability"] = float(round(fake_score, 4))
            if real_score is not None:
                metrics["real_probability"] = float(round(real_score, 4))
            metrics["raw_labels"] = {
                item["label"]: float(round(float(item["score"]), 4))
                for item in predictions
                if "label" in item and "score" in item
            }

            return {
                "verdict": verdict,
                "confidence": float(round(confidence, 4)),
                "metrics": metrics,
            }
        except Exception as e:
            return {
                "verdict": "Uncertain",
                "confidence": 0.0,
                "metrics": {"error": f"Image ML prediction failed: {str(e)}"},
            }
