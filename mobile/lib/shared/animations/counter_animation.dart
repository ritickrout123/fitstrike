import 'package:flutter/material.dart';

class CounterAnimation extends StatefulWidget {
  const CounterAnimation({
    super.key,
    required this.end,
    this.begin = 0,
    this.duration = const Duration(milliseconds: 1200),
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  final double begin;
  final double end;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimals;

  @override
  State<CounterAnimation> createState() => _CounterAnimationState();
}

class _CounterAnimationState extends State<CounterAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: widget.begin, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(CounterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _animation = Tween<double>(begin: _animation.value, end: widget.end).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value.toStringAsFixed(widget.decimals);
        return Text(
          '${widget.prefix}$value${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
