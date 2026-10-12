import argparse
import csv
import os
import pickle
import re
import sys
from pathlib import Path

import cv2
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC


BASE_DIR = Path(__file__).resolve().parent
TEXT_DATASET_DIR = BASE_DIR / "datasets" / "text"
HUMAN_TEXT_DIR = TEXT_DATASET_DIR / "human"
AI_TEXT_DIR = TEXT_DATASET_DIR / "ai"
IMAGE_DATASET_DIR = BASE_DIR / "datasets" / "image"
REAL_IMAGE_DIR = IMAGE_DATASET_DIR / "real"
AI_IMAGE_DIR = IMAGE_DATASET_DIR / "ai"
TEXT_WEIGHTS_DIR = BASE_DIR / "models_weights" / "text"
IMAGE_WEIGHTS_DIR = BASE_DIR / "models_weights" / "image"
IMAGE_SIZE = (256, 256)
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".tif", ".tiff"}

TEXT_COLUMN_CANDIDATES = (
    "text",
    "content",
    "sentence",
    "essay",
    "article",
    "message",
    "response",
    "answer",
    "generated_text",
    "human_text",
)


def preprocess_text(text):
    """Normalize text while preserving enough style signals for AI detection."""
    text = str(text)
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"http\S+|www\.\S+", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip().lower()


def split_txt_samples(content):
    paragraphs = [part.strip() for part in re.split(r"\n\s*\n", content) if part.strip()]
    if len(paragraphs) > 1:
        return paragraphs

    lines = [line.strip() for line in content.splitlines() if line.strip()]
    if len(lines) > 1:
        return lines

    return [content.strip()] if content.strip() else []


def read_txt_file(file_path):
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
    except OSError as exc:
        print(f"Skipping unreadable TXT file {file_path}: {exc}")
        return []

    return split_txt_samples(content)


def pick_text_from_row(row):
    for column_name in TEXT_COLUMN_CANDIDATES:
        value = row.get(column_name)
        if value and value.strip():
            return value

    text_values = []
    for key, value in row.items():
        if key and key.lower() in {"label", "class", "target", "category"}:
            continue
        if value and value.strip():
            text_values.append(value.strip())

    return " ".join(text_values)


def read_csv_file(file_path):
    samples = []
    try:
        with file_path.open("r", encoding="utf-8", errors="ignore", newline="") as csv_file:
            reader = csv.DictReader(csv_file)
            if reader.fieldnames:
                for row in reader:
                    text = pick_text_from_row(row)
                    if text.strip():
                        samples.append(text)
                return samples
    except csv.Error as exc:
        print(f"CSV parsing warning for {file_path}: {exc}")
    except OSError as exc:
        print(f"Skipping unreadable CSV file {file_path}: {exc}")
        return []

    try:
        with file_path.open("r", encoding="utf-8", errors="ignore", newline="") as csv_file:
            reader = csv.reader(csv_file)
            for row in reader:
                text = " ".join(cell.strip() for cell in row if cell.strip())
                if text:
                    samples.append(text)
    except OSError as exc:
        print(f"Skipping unreadable CSV file {file_path}: {exc}")

    return samples


def load_text_samples(class_dir, label):
    if not class_dir.exists():
        raise FileNotFoundError(f"Dataset folder not found: {class_dir}")

    texts = []
    labels = []
    supported_files = sorted(
        path
        for path in class_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in {".txt", ".csv"}
    )

    for file_path in supported_files:
        if file_path.suffix.lower() == ".txt":
            raw_samples = read_txt_file(file_path)
        else:
            raw_samples = read_csv_file(file_path)

        for sample in raw_samples:
            cleaned = preprocess_text(sample)
            if len(cleaned.split()) >= 3:
                texts.append(cleaned)
                labels.append(label)

    return texts, labels


def load_dataset():
    human_texts, human_labels = load_text_samples(HUMAN_TEXT_DIR, 0)
    ai_texts, ai_labels = load_text_samples(AI_TEXT_DIR, 1)

    texts = human_texts + ai_texts
    labels = np.array(human_labels + ai_labels)

    if not texts:
        raise ValueError("No text samples found. Add .txt or .csv files under datasets/text/human and datasets/text/ai.")
    if len(set(labels)) < 2:
        raise ValueError("Both human and AI text samples are required for training.")
    if min(len(human_texts), len(ai_texts)) < 2:
        raise ValueError("Each class needs at least 2 samples for a train/test split.")

    print(f"Loaded {len(human_texts)} human samples from {HUMAN_TEXT_DIR}")
    print(f"Loaded {len(ai_texts)} AI samples from {AI_TEXT_DIR}")
    print(f"Total text samples: {len(texts)}")

    return texts, labels


def train_text_classifier():
    print("Starting TrustLayer text model training...")
    print("\n--- Loading Text Dataset ---")
    texts, labels = load_dataset()

    stratify = labels if min(np.bincount(labels)) >= 2 else None
    X_train, X_test, y_train, y_test = train_test_split(
        texts,
        labels,
        test_size=0.2,
        random_state=42,
        stratify=stratify,
    )

    print("\n--- Vectorizing Text ---")
    vectorizer = TfidfVectorizer(
        stop_words="english",
        ngram_range=(1, 2),
        min_df=2 if len(X_train) >= 50 else 1,
        max_df=0.95,
        sublinear_tf=True,
        max_features=100_000,
    )
    X_train_vec = vectorizer.fit_transform(X_train)
    X_test_vec = vectorizer.transform(X_test)

    print("\n--- Training Logistic Regression Classifier ---")
    classifier = LogisticRegression(
        class_weight="balanced",
        max_iter=1000,
        random_state=42,
        solver="liblinear",
    )
    classifier.fit(X_train_vec, y_train)

    print("\n--- Model Evaluation ---")
    y_pred = classifier.predict(X_test_vec)
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    print("Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred, labels=[0, 1]))
    print("Classification Report:")
    print(classification_report(y_test, y_pred, target_names=["human", "ai"], digits=4))

    TEXT_WEIGHTS_DIR.mkdir(parents=True, exist_ok=True)
    with (TEXT_WEIGHTS_DIR / "tfidf_vectorizer.pkl").open("wb") as file:
        pickle.dump(vectorizer, file)
    with (TEXT_WEIGHTS_DIR / "text_classifier.pkl").open("wb") as file:
        pickle.dump(classifier, file)

    print("\nSaved text vectorizer and classifier successfully.")
    print(f"Vectorizer: {TEXT_WEIGHTS_DIR / 'tfidf_vectorizer.pkl'}")
    print(f"Classifier: {TEXT_WEIGHTS_DIR / 'text_classifier.pkl'}")


def preprocess_image(image_path):
    image = cv2.imread(str(image_path))
    if image is None:
        raise ValueError(f"Could not load image: {image_path}")

    resized = cv2.resize(image, IMAGE_SIZE, interpolation=cv2.INTER_AREA)
    gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)

    return {
        "bgr": resized,
        "gray": gray,
    }


def extract_image_features(preprocessed_image):
    bgr = preprocessed_image["bgr"]
    gray = preprocessed_image["gray"]
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

    texture_stats = np.array(
        [
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
        ],
        dtype=np.float32,
    )

    color_stats = []
    for channel_index in range(3):
        channel = rgb[:, :, channel_index]
        color_stats.extend(
            [
                float(np.mean(channel)),
                float(np.std(channel)),
                float(np.var(channel)),
            ]
        )

    return np.concatenate(
        [
            *color_histograms,
            np.array(color_stats, dtype=np.float32),
            texture_stats,
        ]
    )


def load_image_samples(class_dir, label):
    if not class_dir.exists():
        raise FileNotFoundError(f"Dataset folder not found: {class_dir}")

    features = []
    labels = []
    image_files = sorted(
        path
        for path in class_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )

    for image_path in image_files:
        try:
            preprocessed = preprocess_image(image_path)
            features.append(extract_image_features(preprocessed))
            labels.append(label)
        except Exception as exc:
            print(f"Skipping image {image_path}: {exc}")

    return features, labels


def load_image_dataset():
    real_features, real_labels = load_image_samples(REAL_IMAGE_DIR, 0)
    ai_features, ai_labels = load_image_samples(AI_IMAGE_DIR, 1)

    features = real_features + ai_features
    labels = np.array(real_labels + ai_labels)

    if not features:
        raise ValueError("No image samples found. Add image files under datasets/image/real and datasets/image/ai.")
    if len(set(labels)) < 2:
        raise ValueError("Both real and AI image samples are required for training.")
    if min(len(real_features), len(ai_features)) < 2:
        raise ValueError("Each image class needs at least 2 samples for a train/test split.")

    print(f"Loaded {len(real_features)} real images from {REAL_IMAGE_DIR}")
    print(f"Loaded {len(ai_features)} AI images from {AI_IMAGE_DIR}")
    print(f"Total image samples: {len(features)}")

    return np.vstack(features), labels


def train_image_classifier():
    print("\n--- Loading Image Dataset ---")
    features, labels = load_image_dataset()

    X_train, X_test, y_train, y_test = train_test_split(
        features,
        labels,
        test_size=0.2,
        random_state=42,
        stratify=labels,
    )

    candidates = {
        "random_forest": Pipeline(
            [
                ("scaler", StandardScaler()),
                (
                    "classifier",
                    RandomForestClassifier(
                        n_estimators=250,
                        class_weight="balanced",
                        random_state=42,
                        n_jobs=-1,
                    ),
                ),
            ]
        ),
        "svm": Pipeline(
            [
                ("scaler", StandardScaler()),
                (
                    "classifier",
                    SVC(
                        kernel="rbf",
                        C=3.0,
                        gamma="scale",
                        class_weight="balanced",
                        probability=True,
                        random_state=42,
                    ),
                ),
            ]
        ),
    }

    evaluations = {}
    print("\n--- Training and Comparing Image Classifiers ---")
    for model_name, classifier in candidates.items():
        classifier.fit(X_train, y_train)
        y_pred = classifier.predict(X_test)
        metrics = {
            "accuracy": float(accuracy_score(y_test, y_pred)),
            "precision": float(precision_score(y_test, y_pred, zero_division=0)),
            "recall": float(recall_score(y_test, y_pred, zero_division=0)),
            "f1": float(f1_score(y_test, y_pred, zero_division=0)),
            "confusion_matrix": confusion_matrix(y_test, y_pred, labels=[0, 1]).tolist(),
        }
        evaluations[model_name] = {
            "model": classifier,
            "metrics": metrics,
        }

        print(f"\n{model_name} metrics:")
        print(f"Accuracy: {metrics['accuracy']:.4f}")
        print(f"Precision: {metrics['precision']:.4f}")
        print(f"Recall: {metrics['recall']:.4f}")
        print(f"F1 Score: {metrics['f1']:.4f}")
        print("Confusion Matrix:")
        print(np.array(metrics["confusion_matrix"]))

    best_model_name = max(
        evaluations,
        key=lambda name: (evaluations[name]["metrics"]["accuracy"], evaluations[name]["metrics"]["f1"]),
    )
    best_model = evaluations[best_model_name]["model"]
    best_metrics = evaluations[best_model_name]["metrics"]

    IMAGE_WEIGHTS_DIR.mkdir(parents=True, exist_ok=True)
    with (IMAGE_WEIGHTS_DIR / "image_classifier.pkl").open("wb") as file:
        pickle.dump(
            {
                "model": best_model,
                "model_name": best_model_name,
                "labels": {0: "real", 1: "ai"},
                "image_size": IMAGE_SIZE,
                "feature_version": "opencv_handcrafted_v1",
                "metrics": best_metrics,
                "all_model_metrics": {
                    name: result["metrics"] for name, result in evaluations.items()
                },
            },
            file,
        )

    print(f"\nBest image model: {best_model_name}")
    print(f"Best accuracy: {best_metrics['accuracy']:.4f}")
    print("Saved image classifier successfully.")
    print(f"Classifier: {IMAGE_WEIGHTS_DIR / 'image_classifier.pkl'}")


def run_training(mode):
    trainers = []
    if mode in {"all", "text"}:
        trainers.append(("text", train_text_classifier))
    if mode in {"all", "image"}:
        trainers.append(("image", train_image_classifier))

    trained_count = 0
    for model_name, trainer in trainers:
        try:
            trainer()
            trained_count += 1
        except (FileNotFoundError, ValueError) as exc:
            print(f"\nSkipping {model_name} training: {exc}")
            if mode != "all":
                raise

    if trained_count == 0:
        raise ValueError("No models were trained. Add dataset files or choose a mode with available data.")


def parse_args():
    parser = argparse.ArgumentParser(description="Train TrustLayer ML models from real datasets.")
    parser.add_argument(
        "--mode",
        choices=["all", "text", "image"],
        default="all",
        help="Choose which model to train. Defaults to all available datasets.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    try:
        run_training(args.mode)
    except Exception as exc:
        print(f"\nTraining failed: {exc}")
        sys.exit(1)
