import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class TLButton extends StatelessWidget {
  const TLButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final textStyle = Theme.of(context).textTheme.labelLarge;

    return AnimatedOpacity(
      opacity: isEnabled ? 1 : 0.65,
      duration: const Duration(milliseconds: 180),
      child: SizedBox(
        width: expand ? double.infinity : null,
        height: height,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled && !isOutlined
                ? [
                    BoxShadow(
                      color: AppTheme.electricBlue.withOpacity(0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: isOutlined
              ? OutlinedButton(
                  onPressed: isEnabled ? onPressed : null,
                  style: _outlinedStyle(textStyle),
                  child: _ButtonContent(
                    label: label,
                    icon: icon,
                    isLoading: isLoading,
                  ),
                )
              : FilledButton(
                  onPressed: isEnabled ? onPressed : null,
                  style: _filledStyle(textStyle),
                  child: _ButtonContent(
                    label: label,
                    icon: icon,
                    isLoading: isLoading,
                  ),
                ),
        ),
      ),
    );
  }

  ButtonStyle _filledStyle(TextStyle? textStyle) {
    return FilledButton.styleFrom(
      backgroundColor: AppTheme.electricBlue,
      foregroundColor: AppTheme.textMain,
      disabledBackgroundColor: AppTheme.surfaceRaised,
      disabledForegroundColor: AppTheme.textMuted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: textStyle,
    );
  }

  ButtonStyle _outlinedStyle(TextStyle? textStyle) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.cyberCyan,
      disabledForegroundColor: AppTheme.textMuted,
      side: BorderSide(color: AppTheme.cyberCyan.withOpacity(0.45)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: textStyle,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textMain,
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }
}
