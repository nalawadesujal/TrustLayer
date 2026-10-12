import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/presentation/providers/detection_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/presentation/widgets/detection_result_panel.dart';

class ImageDetectScreen extends StatefulWidget {
  const ImageDetectScreen({super.key});

  @override
  State<ImageDetectScreen> createState() => _ImageDetectScreenState();
}

class _ImageDetectScreenState extends State<ImageDetectScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
        context.read<DetectionProvider>().reset();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.errorRed),
      );
    }
  }

  void _analyze() {
    if (_selectedImagePath == null) return;
    context.read<DetectionProvider>().analyzeImage(_selectedImagePath!);
  }

  @override
  Widget build(BuildContext context) {
    final detectionProvider = context.watch<DetectionProvider>();
    final result = detectionProvider.lastResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Detector"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (detectionProvider.isLoading)
                _buildLoadingState()
              else if (result != null && result.modality == 'image')
                _buildResultState(result)
              else
                _buildInputState(detectionProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputState(DetectionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Analyze Visual Media",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain),
        ),
        const SizedBox(height: 6),
        const Text(
          "Upload an image to compute its Discrete Fourier Transform (DFT) signature and scan for periodic grid frequencies typical of AI generators.",
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // Image box preview
        if (_selectedImagePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: Image.file(
                File(_selectedImagePath!),
                fit: coverFit(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF161420),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A273F), width: 1),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 56, color: AppTheme.textMuted),
                SizedBox(height: 12),
                Text(
                  "No Image Selected",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Pick image actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMain,
                  side: const BorderSide(color: Color(0xFF2A273F)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_outlined, size: 20),
                label: const Text("Gallery"),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMain,
                  side: const BorderSide(color: Color(0xFF2A273F)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text("Camera"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (provider.errorMessage != null) ...[
          Text(
            provider.errorMessage!,
            style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],

        if (_selectedImagePath != null)
          ElevatedButton(
            onPressed: _analyze,
            child: const Text("Analyze Image"),
          ),
      ],
    );
  }

  BoxFit coverFit() => BoxFit.cover;

  Widget _buildLoadingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100),
        CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
        SizedBox(height: 48),
        Text(
          "Computing Spatial Spectrum...",
          style: TextStyle(
              fontSize: 18,
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Running 2D Discrete Fourier Transform (DFT) and extracting HSV distributions",
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultState(DetectionModel model) {
    return DetectionResultPanel(
      title: "Image Analysis Results",
      model: model,
      accentColor: Colors.blueAccent,
      metricsTitle: "OPENCV IMAGE METRICS",
      resetLabel: "Analyze New Image",
      metrics: [
        DetectionMetric("Model", _metric(model, 'model_name')),
        DetectionMetric(
          "AI Probability",
          "${_percentMetric(model, 'ai_probability')}%",
        ),
        DetectionMetric(
          "Real Probability",
          "${_percentMetric(model, 'real_probability')}%",
        ),
        DetectionMetric(
          "Brightness Mean",
          _metric(model, 'brightness_mean'),
        ),
        DetectionMetric(
          "Brightness Std Dev",
          _metric(model, 'brightness_std'),
        ),
        DetectionMetric("Edge Density", _metric(model, 'edge_density')),
        DetectionMetric(
          "Laplacian Sharpness",
          _metric(model, 'laplacian_variance'),
        ),
        DetectionMetric(
          "Inference Pipeline",
          model.metadata['ml_mode'] == true
              ? "OpenCV Features + ML Classifier"
              : "Image Heuristics",
        ),
      ],
      onReset: () {
        setState(() {
          _selectedImagePath = null;
        });
        context.read<DetectionProvider>().reset();
      },
    );
  }

  String _metric(DetectionModel model, String key) {
    return model.metadata[key]?.toString() ?? 'N/A';
  }

  String _percentMetric(DetectionModel model, String key) {
    final value = model.metadata[key];
    if (value is num) {
      return (value * 100).toStringAsFixed(1);
    }
    return 'N/A';
  }
}
