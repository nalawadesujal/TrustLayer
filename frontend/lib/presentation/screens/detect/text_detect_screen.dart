import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/detection_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/presentation/widgets/detection_result_panel.dart';

class TextDetectScreen extends StatefulWidget {
  const TextDetectScreen({super.key});

  @override
  State<TextDetectScreen> createState() => _TextDetectScreenState();
}

class _TextDetectScreenState extends State<TextDetectScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _analyze() {
    if (!_formKey.currentState!.validate()) return;

    context.read<DetectionProvider>().analyzeText(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    final detectionProvider = context.watch<DetectionProvider>();
    final result = detectionProvider.lastResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Detector"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (detectionProvider.isLoading)
                _buildLoadingState()
              else if (result != null && result.modality == 'text')
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Analyze Written Content",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain),
          ),
          const SizedBox(height: 6),
          const Text(
            "Paste your text below to extract stylometric indicators and predict AI authorship.",
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _textController,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: "Enter at least 10 characters here...",
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().length < 10) {
                return "Please enter a longer text sample (minimum 10 characters).";
              }
              return null;
            },
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
          ElevatedButton(
            onPressed: _analyze,
            child: const Text("Analyze Text"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100),
        CircularProgressIndicator(
          color: AppTheme.primaryPurple,
        ),
        SizedBox(height: 48),
        Text(
          "Running Stylometric Models...",
          style: TextStyle(
              fontSize: 18,
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Tokenizing N-grams and scoring TF-IDF statistics",
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildResultState(DetectionModel model) {
    return DetectionResultPanel(
      title: "Analysis Completed",
      model: model,
      accentColor: AppTheme.primaryPurple,
      metricsTitle: "NLTK DIAGNOSTICS",
      resetLabel: "Analyze New Text",
      metrics: [
        DetectionMetric(
          "Average Sentence Length",
          "${_metric(model, 'avg_sentence_length')} words",
        ),
        DetectionMetric(
          "Average Word Size",
          "${_metric(model, 'avg_word_length')} chars",
        ),
        DetectionMetric(
          "Lexical Diversity (TTR)",
          _metric(model, 'lexical_diversity'),
        ),
        DetectionMetric(
          "Inference Pipeline",
          model.metadata['ml_mode'] == true
              ? "TF-IDF + LogisticRegression"
              : "Rule-Based Fallback",
        ),
      ],
      onReset: () {
        _textController.clear();
        context.read<DetectionProvider>().reset();
      },
    );
  }

  String _metric(DetectionModel model, String key) {
    return model.metadata[key]?.toString() ?? 'N/A';
  }
}
