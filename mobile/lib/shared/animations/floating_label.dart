import 'package:flutter/material.dart';
import '../../core/animations/animation_constants.dart';

class FloatingLabel extends StatefulWidget {
  const FloatingLabel({
    super.key,
    required this.text,
    required this.color,
    required this.position,
    this.onRemove,
  });

  final String text;
  final Color color;
  final Offset position;
  final VoidCallback? onRemove;

  @override
  State<FloatingLabel> createState() => _FloatingLabelState();
}

class _FloatingLabelState extends State<FloatingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _translateY = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onRemove?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 40,
      top: widget.position.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Barlow Condensed',
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
