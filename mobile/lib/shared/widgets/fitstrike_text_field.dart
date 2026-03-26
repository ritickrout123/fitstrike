import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class FitStrikeTextField extends StatefulWidget {
  const FitStrikeTextField({
    super.key,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  State<FitStrikeTextField> createState() => _FitStrikeTextFieldState();
}

class _FitStrikeTextFieldState extends State<FitStrikeTextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusController.repeat(reverse: true);
    } else {
      _focusController.stop();
      _focusController.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _focusController,
          builder: (context, child) {
            final glowValue = _focusController.value;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (_focusNode.hasFocus)
                    BoxShadow(
                      color: AppColors.lime.withValues(alpha: 0.05 + (glowValue * 0.1)),
                      blurRadius: 10 + (glowValue * 10),
                      spreadRadius: 1 + (glowValue * 2),
                    ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                  filled: true,
                  fillColor: AppColors.surface,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.lerp(AppColors.lime, AppColors.cyan, glowValue) ?? AppColors.lime,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.rose),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
