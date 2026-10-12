from app.ml.image_detector import ImageDetector

detector = ImageDetector()

result = detector.predict("test1.jpg")

print(result)