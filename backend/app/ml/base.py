from abc import ABC, abstractmethod

class BaseDetector(ABC):
    @abstractmethod
    def preprocess(self, input_data):
        """Loads and cleans raw input data."""
        pass

    @abstractmethod
    def extract_features(self, preprocessed_data):
        """Extracts numeric feature vectors representing model properties."""
        pass

    @abstractmethod
    def predict(self, input_data) -> dict:
        """Performs inference.
        
        Returns:
            dict: {
                'verdict': 'ai' | 'human',
                'confidence': float (0.0 to 1.0),
                'metrics': dict (extra diagnostic data)
            }
        """
        pass
