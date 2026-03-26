import 'package:flutter/material.dart';
import '../../core/animations/animation_constants.dart';
import '../../../../config/theme.dart';
import 'counter_animation.dart';

class CaptureResultOverlay extends StatefulWidget {
  const CaptureResultOverlay({
    super.key,
    required this.area,
    required this.xp,
    required this.coins,
    required this.onDismiss,
  });

  final double area;
  final int xp;
  final int coins;
  final VoidCallback onDismiss;

  @override
  State<CaptureResultOverlay> createState() => _CaptureResultOverlayState();
}

class _CaptureResultOverlayState extends State<CaptureResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slow, // 400ms
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lime.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.lime.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 64),
              const SizedBox(height: 16),
              Text(
                'TERRITORY SECURED',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(height: 24),
              
              _StatRow(
                label: 'AREA CAPTURED',
                value: widget.area,
                suffix: ' m²',
                decimals: 1,
                color: Colors.white,
              ),
              const Divider(color: AppColors.border, height: 24),
              _StatRow(
                label: 'XP EARNED',
                value: widget.xp.toDouble(),
                prefix: '+',
                suffix: ' XP',
                color: AppColors.cyan,
              ),
              const Divider(color: AppColors.border, height: 24),
              _StatRow(
                label: 'STRIKE COINS',
                value: widget.coins.toDouble(),
                prefix: '+',
                suffix: ' SC',
                color: AppColors.amber,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CONFIRM LOG'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    required this.color,
  });

  final String label;
  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        CounterAnimation(
          end: value,
          prefix: prefix,
          suffix: suffix,
          decimals: decimals,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
