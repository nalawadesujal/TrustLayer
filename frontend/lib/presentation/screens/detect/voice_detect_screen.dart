import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/presentation/providers/detection_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/presentation/widgets/detection_result_panel.dart';

class VoiceDetectScreen extends StatefulWidget {
  const VoiceDetectScreen({super.key});

  @override
  State<VoiceDetectScreen> createState() => _VoiceDetectScreenState();
}

class _VoiceDetectScreenState extends State<VoiceDetectScreen> {
  String? _selectedAudioPath;
  String? _selectedAudioName;

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'ogg', 'm4a'],
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() {
          _selectedAudioPath = result.files.single.path;
          _selectedAudioName = result.files.single.name;
        });
        context.read<DetectionProvider>().reset();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to pick audio file: $e'),
            backgroundColor: AppTheme.errorRed),
      );
    }
  }

  void _analyze() {
    if (_selectedAudioPath == null) return;
    context.read<DetectionProvider>().analyzeVoice(_selectedAudioPath!);
  }

  @override
  Widget build(BuildContext context) {
    final detectionProvider = context.watch<DetectionProvider>();
    final result = detectionProvider.lastResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Detector"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (detectionProvider.isLoading)
                _buildLoadingState()
              else if (result != null && result.modality == 'voice')
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
          "Analyze Acoustic Voiceprints",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain),
        ),
        const SizedBox(height: 6),
        const Text(
          "Select a voice recording or audio sample to analyze its mel-frequency coefficients and evaluate dynamic voice variance.",
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // File selection box
        GestureDetector(
          onTap: _pickAudio,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF161420),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedAudioPath != null
                    ? AppTheme.secondaryCyan
                    : const Color(0xFF2A273F),
                width: _selectedAudioPath != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedAudioPath != null
                      ? Icons.audiotrack
                      : Icons.audio_file_outlined,
                  size: 56,
                  color: _selectedAudioPath != null
                      ? AppTheme.secondaryCyan
                      : AppTheme.textMuted,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _selectedAudioName ?? "Tap to Select Audio File",
                    style: TextStyle(
                      color: _selectedAudioPath != null
                          ? AppTheme.textMain
                          : AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: _selectedAudioPath != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedAudioPath == null) ...[
                  const SizedBox(height: 6),
                  const Text(
                    "Supports WAV, MP3, OGG, or M4A",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        if (provider.errorMessage != null) ...[
          Text(
            provider.errorMessage!,
            style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],

        if (_selectedAudioPath != null)
          ElevatedButton(
            onPressed: _analyze,
            child: const Text("Analyze Audio File"),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 120),
        CircularProgressIndicator(
          color: AppTheme.secondaryCyan,
        ),
        SizedBox(height: 52),
        Text(
          "Deconstructing Audio waveform...",
          style: TextStyle(
              fontSize: 18,
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Extracting Mel-Frequency Cepstral Coefficients (MFCCs) and spectral centroid variance using Librosa",
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultState(DetectionModel model) {
    return DetectionResultPanel(
      title: "Acoustic Analysis Results",
      model: model,
      accentColor: AppTheme.secondaryCyan,
      metricsTitle: "LIBROSA ACOUSTIC METRICS",
      resetLabel: "Analyze New Voice Clip",
      metrics: [
        DetectionMetric(
          "Average MFCC Variance",
          _metric(model, 'avg_mfcc_variance'),
        ),
        DetectionMetric(
          "Spectral Centroid",
          "${_metric(model, 'spectral_centroid_hz')} Hz",
        ),
        DetectionMetric(
          "Spectral Rolloff",
          "${_metric(model, 'spectral_rolloff_hz')} Hz",
        ),
        DetectionMetric(
          "Zero Crossing Rate",
          _metric(model, 'zero_crossing_rate'),
        ),
        DetectionMetric(
          "Inference Pipeline",
          model.metadata['ml_mode'] == true
              ? "Mel-MFCCs + RandomForest"
              : "Acoustic Variance Heuristics",
        ),
      ],
      onReset: () {
        setState(() {
          _selectedAudioPath = null;
          _selectedAudioName = null;
        });
        context.read<DetectionProvider>().reset();
      },
    );
  }

  String _metric(DetectionModel model, String key) {
    return model.metadata[key]?.toString() ?? 'N/A';
  }
}
