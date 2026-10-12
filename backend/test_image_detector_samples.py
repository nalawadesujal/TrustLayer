import argparse
import os
from collections import Counter

from app.ml.image_detector import ImageDetector

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))


def collect_images(directory, limit):
    paths = []
    for name in sorted(os.listdir(directory)):
        path = os.path.join(directory, name)
        if os.path.isfile(path) and os.path.splitext(name)[1].lower() in IMAGE_EXTENSIONS:
            paths.append(path)
        if len(paths) == limit:
            break
    return paths


def evaluate(detector, labeled_paths):
    stats = Counter()

    for expected, path in labeled_paths:
        result = detector.predict(path)
        predicted = result["verdict"]
        confidence = result["confidence"]

        stats["total"] += 1
        stats[f"expected_{expected}"] += 1
        stats[f"predicted_{predicted}"] += 1

        if predicted == expected:
            stats["correct"] += 1
        elif predicted == "Uncertain":
            stats["uncertain"] += 1
        else:
            stats["incorrect"] += 1

        print(
            f"{os.path.basename(path):<24} "
            f"expected={expected:<4} predicted={predicted:<9} confidence={confidence:.4f}"
        )

    return stats


def print_summary(stats):
    total = stats["total"]
    decided = total - stats["uncertain"]
    decided_accuracy = stats["correct"] / decided if decided else 0.0
    overall_accuracy = stats["correct"] / total if total else 0.0

    print("\nPrediction statistics")
    print(f"total={total}")
    print(f"correct={stats['correct']}")
    print(f"incorrect={stats['incorrect']}")
    print(f"uncertain={stats['uncertain']}")
    print(f"overall_accuracy={overall_accuracy:.2%}")
    print(f"decided_accuracy={decided_accuracy:.2%}")
    print(f"predicted_ai={stats['predicted_ai']}")
    print(f"predicted_real={stats['predicted_real']}")
    print(f"predicted_uncertain={stats['predicted_Uncertain']}")


def main():
    parser = argparse.ArgumentParser(
        description="Evaluate TrustLayer image detector on 10 real and 10 AI images."
    )
    parser.add_argument(
        "--real-dir",
        default=os.path.join(BACKEND_DIR, "datasets", "image", "real"),
        help="Directory containing real images.",
    )
    parser.add_argument(
        "--ai-dir",
        default=os.path.join(BACKEND_DIR, "datasets", "image", "ai"),
        help="Directory containing AI-generated images.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=10,
        help="Number of images to read from each class.",
    )
    args = parser.parse_args()

    real_paths = collect_images(args.real_dir, args.limit)
    ai_paths = collect_images(args.ai_dir, args.limit)

    if len(real_paths) < args.limit or len(ai_paths) < args.limit:
        raise SystemExit(
            f"Expected at least {args.limit} images in each folder; "
            f"found real={len(real_paths)}, ai={len(ai_paths)}."
        )

    detector = ImageDetector()
    labeled_paths = [("real", path) for path in real_paths]
    labeled_paths.extend(("ai", path) for path in ai_paths)

    stats = evaluate(detector, labeled_paths)
    print_summary(stats)


if __name__ == "__main__":
    main()
