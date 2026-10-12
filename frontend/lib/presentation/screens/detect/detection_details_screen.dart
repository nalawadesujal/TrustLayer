import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/presentation/widgets/glass_card.dart';
import 'package:frontend/presentation/widgets/result_badge.dart';
import 'package:intl/intl.dart';

class DetectionDetailsScreen extends StatelessWidget {
  const DetectionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = ModalRoute.of(context)?.settings.arguments as DetectionModel?;

    return Scaffold(
      appBar: AppBar(title: const Text('Detection Details')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: model == null
              ? const Center(
                  child: Text(
                    'No detection details found.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResultBadge(
                              type: ResultBadge.typeFromVerdict(model.verdict),
                              confidence: model.confidence,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              model.inputSummary,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM dd, yyyy • hh:mm a')
                                  .format(model.createdAt.toLocal()),
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _DetailLine(
                              label: 'Modality',
                              value: model.modality.toUpperCase(),
                            ),
                            _DetailLine(
                              label: 'Confidence',
                              value:
                                  '${model.confidencePercentage.toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metrics',
                              style: TextStyle(
                                color: AppTheme.textMain,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (model.metadata.isEmpty)
                              const Text(
                                'No metrics available for this scan.',
                                style: TextStyle(color: AppTheme.textMuted),
                              )
                            else
                              for (final entry in model.metadata.entries)
                                _DetailLine(
                                  label: entry.key,
                                  value: entry.value.toString(),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
