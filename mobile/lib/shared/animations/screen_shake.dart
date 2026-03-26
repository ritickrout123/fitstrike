import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScreenShake extends StatefulWidget {
  const ScreenShake({
    super.key,
    required this.child,
    this.intensity = 6.0,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final double intensity;
  final Duration duration;

  @override
  State<ScreenShake> createState() => ScreenShakeState();
}

class ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0).then((_) => _controller.reset());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double sineValue = math.sin(_controller.value * math.pi * 8); // 4 cycles
        final double offset = sineValue * widget.intensity * (1.0 - _controller.value);
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
