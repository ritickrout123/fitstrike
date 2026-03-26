import 'package:flutter/material.dart';
import '../../core/animations/animation_constants.dart';
import '../../../../config/theme.dart';
import '../animations/fade_slide_in.dart';

class FitStrikeCard extends StatelessWidget {
  const FitStrikeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.delay = Duration.zero,
    this.title,
    this.subtitle,
    this.trailing,
    this.borderColor,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Duration delay;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Color? borderColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppColors.borderStrong,
          width: 1,
        ),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            fontSize: 14,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      );
    }

    return FadeSlideIn(
      delay: delay,
      child: content,
    );
  }
}
