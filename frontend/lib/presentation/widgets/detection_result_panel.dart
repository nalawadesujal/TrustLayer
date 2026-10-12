import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/presentation/widgets/glass_card.dart';
import 'package:frontend/presentation/widgets/result_badge.dart';
import 'package:intl/intl.dart';

class DetectionMetric {
  const DetectionMetric(this.label, this.value);

  final String label;
  final String value;
}

class DetectionResultPanel extends StatelessWidget {
  const DetectionResultPanel({
    super.key,
    required this.title,
    required this.model,
    required this.accentColor,
    required this.metricsTitle,
    required this.metrics,
    required this.onReset,
    required this.resetLabel,
  });

  final String title;
  final DetectionModel model;
  final Color accentColor;
  final String metricsTitle;
  final List<DetectionMetric> metrics;
  final VoidCallback onReset;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    final badgeType = ResultBadge.typeFromVerdict(model.verdict);
    final resultColor = _colorForBadge(badgeType);
    final timestamp = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(model.createdAt.toLocal());

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Column(
        key: ValueKey(model.id),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Scanned $timestamp',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                ResultBadge(type: badgeType, confidence: model.confidence),
                const SizedBox(height: 24),
                _ConfidenceMeter(
                  confidence: model.confidence,
                  color: resultColor,
                ),
                const SizedBox(height: 22),
                Text(
                  '${model.confidencePercentage.toStringAsFixed(1)}% confidence',
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Model confidence score for this scan',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: accentColor.withOpacity(0.08),
                highlightColor: accentColor.withOpacity(0.06),
              ),
              child: ExpansionTile(
                iconColor: accentColor,
                collapsedIconColor: AppTheme.textMuted,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                title: Text(
                  metricsTitle,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                subtitle: const Text(
                  'Tap to view diagnostic details',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                children: [
                  for (var index = 0; index < metrics.length; index++) ...[
                    _MetricRow(metric: metrics[index]),
                    if (index != metrics.length - 1)
                      Divider(color: AppTheme.outlineBlue.withOpacity(0.75)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onReset,
            child: Text(resetLabel),
          ),
        ],
      ),
    );
  }

  Color _colorForBadge(ResultBadgeType type) {
    switch (type) {
      case ResultBadgeType.aiGenerated:
        return AppTheme.errorRed;
      case ResultBadgeType.realContent:
        return AppTheme.successGreen;
      case ResultBadgeType.uncertain:
        return AppTheme.cyberCyan;
    }
  }
}

class _ConfidenceMeter extends StatelessWidget {
  const _ConfidenceMeter({required this.confidence, required this.color});

  final double confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: confidence.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 168,
          height: 168,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 142,
                height: 142,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceRaised.withOpacity(0.62),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 156,
                height: 156,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: AppTheme.outlineBlue.withOpacity(0.55),
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final DetectionMetric metric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              metric.label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              metric.value,
              style: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
