import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class TLTextField extends StatefulWidget {
  const TLTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.isLoading = false,
    this.onChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final bool isLoading;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  State<TLTextField> createState() => _TLTextFieldState();
}

class _TLTextFieldState extends State<TLTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final isEnabled = widget.enabled && !widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.cyberCyan.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: isEnabled,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        obscureText: widget.obscureText,
        onChanged: widget.onChanged,
        validator: widget.validator,
        style: const TextStyle(color: AppTheme.textMain),
        cursorColor: AppTheme.cyberCyan,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon:
              widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
          suffixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.cyberCyan,
                    ),
                  ),
                )
              : widget.suffixIcon,
          filled: true,
          fillColor: isFocused ? AppTheme.surfaceRaised : AppTheme.surfaceCard,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: _border(AppTheme.outlineBlue),
          disabledBorder: _border(AppTheme.outlineBlue.withOpacity(0.45)),
          focusedBorder: _border(AppTheme.cyberCyan, width: 1.6),
          errorBorder: _border(AppTheme.errorRed),
          focusedErrorBorder: _border(AppTheme.errorRed, width: 1.6),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
