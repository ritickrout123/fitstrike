import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class FitStrikeShimmer extends StatefulWidget {
  const FitStrikeShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 10,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<FitStrikeShimmer> createState() => _FitStrikeShimmerState();
}

class _FitStrikeShimmerState extends State<FitStrikeShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              colors: [
                AppColors.surface,
                AppColors.surfaceMuted,
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}
