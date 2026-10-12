import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

enum ResultBadgeType {
  aiGenerated,
  realContent,
  uncertain,
}

class ResultBadge extends StatelessWidget {
  const ResultBadge({
    super.key,
    required this.type,
    this.confidence,
    this.compact = false,
  });

  final ResultBadgeType type;
  final double? confidence;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type);
    final confidenceText = confidence == null
        ? null
        : '${(confidence!.clamp(0, 1) * 100).toStringAsFixed(0)}%';

    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: style.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          border: Border.all(color: style.color.withOpacity(0.34)),
          boxShadow: [
            BoxShadow(
              color: style.color.withOpacity(0.24),
              blurRadius: 22,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, color: style.color, size: compact ? 18 : 20),
            SizedBox(width: compact ? 7 : 9),
            Text(
              confidenceText == null
                  ? style.label
                  : '${style.label}  $confidenceText',
              style: TextStyle(
                color: style.color,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BadgeStyle _styleFor(ResultBadgeType type) {
    switch (type) {
      case ResultBadgeType.aiGenerated:
        return const _BadgeStyle(
          label: 'AI Generated',
          icon: Icons.auto_awesome_outlined,
          color: AppTheme.errorRed,
        );
      case ResultBadgeType.realContent:
        return const _BadgeStyle(
          label: 'Real Content',
          icon: Icons.verified_outlined,
          color: AppTheme.successGreen,
        );
      case ResultBadgeType.uncertain:
        return const _BadgeStyle(
          label: 'Uncertain',
          icon: Icons.help_outline,
          color: AppTheme.cyberCyan,
        );
    }
  }

  static ResultBadgeType typeFromVerdict(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'ai':
      case 'ai generated':
        return ResultBadgeType.aiGenerated;
      case 'real':
      case 'human':
      case 'real content':
        return ResultBadgeType.realContent;
      default:
        return ResultBadgeType.uncertain;
    }
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
