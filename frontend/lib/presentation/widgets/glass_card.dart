import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 16,
    this.backgroundOpacity = 0.18,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsivePadding =
        screenWidth < 600 ? const EdgeInsets.all(16) : const EdgeInsets.all(22);
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? responsivePadding,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard.withOpacity(backgroundOpacity),
              borderRadius: radius,
              border: Border.all(
                color: AppTheme.cyberCyan.withOpacity(0.18),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
