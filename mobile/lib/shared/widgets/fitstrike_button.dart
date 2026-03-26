import 'package:flutter/material.dart';
import '../../core/animations/animation_constants.dart';
import '../../../../config/theme.dart';
import '../animations/scale_punch.dart';

enum FitStrikeButtonVariant { primary, secondary, outline, ghost }

class FitStrikeButton extends StatelessWidget {
  const FitStrikeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FitStrikeButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final FitStrikeButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return ScalePunch(
      onTap: isDisabled ? () {} : onPressed!,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Container(
          width: width,
          height: height,
          decoration: _getDecoration(),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: _getTextColor()),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          color: _getTextColor(),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case FitStrikeButtonVariant.primary:
        return BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.lime.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case FitStrikeButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderStrong),
        );
      case FitStrikeButtonVariant.outline:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lime, width: 2),
        );
      case FitStrikeButtonVariant.ghost:
        return const BoxDecoration();
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case FitStrikeButtonVariant.primary:
        return Colors.black;
      default:
        return Colors.white;
    }
  }
}
