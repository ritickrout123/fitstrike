import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class FitStrikeLoader extends StatefulWidget {
  const FitStrikeLoader({
    super.key,
    this.size = 160.0,
    this.showProgress = false,
    this.progress = 0.0,
    this.status = 'Initializing...',
    this.fullScreen = false,
  });

  final double size;
  final bool showProgress;
  final double progress;
  final String status;
  final bool fullScreen;

  @override
  State<FitStrikeLoader> createState() => _FitStrikeLoaderState();
}

class _FitStrikeLoaderState extends State<FitStrikeLoader>
    with TickerProviderStateMixin {
  late final AnimationController _ringAController;
  late final AnimationController _ringBController;
  late final AnimationController _pulseController;
  late final AnimationController _scanController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _ringAController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _ringBController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringAController.dispose();
    _ringBController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.fullScreen) {
      return _buildCoreLoader();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080A10),
      body: Stack(
        children: [
          _buildGridBackground(),
          _buildRadialGlow(),
          _buildScanline(),
          _buildCornerAccents(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCoreLoader(),
                const SizedBox(height: 28),
                _buildWordmark(),
                const SizedBox(height: 10),
                _buildTagline(),
                if (widget.showProgress) ...[
                  const SizedBox(height: 56),
                  _buildProgressSection(),
                ],
              ],
            ),
          ),
          _buildBottomTag(),
        ],
      ),
    );
  }

  Widget _buildCoreLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_ringAController, _ringBController, _pulseController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring 1 (Lime)
              RotationTransition(
                turns: _ringAController,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.lime.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.lime,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lime,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Ring 2 (Blue)
              RotationTransition(
                turns: _ringBController,
                child: Container(
                  width: widget.size - 20,
                  height: widget.size - 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF378ADD).withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              // Logo with Pulse
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                  CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: widget.size * 0.52,
                  height: widget.size * 0.52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lime.withValues(alpha: 0.4 * _pulseController.value),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/fs.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.5 + (_glowController.value * 0.5),
        child: CustomPaint(
          painter: _GridPainter(),
        ),
      ),
    );
  }

  Widget _buildRadialGlow() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 600 * (1.0 + _glowController.value * 0.2),
            height: 600 * (1.0 + _glowController.value * 0.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.lime.withValues(alpha: 0.06 * (0.6 + _glowController.value * 0.4)),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanline() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        final top = MediaQuery.of(context).size.height * _scanController.value;
        return Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: math.sin(_scanController.value * math.pi),
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.lime, Colors.transparent],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerAccents() {
    return Stack(
      children: [
        _buildCorner(Alignment.topLeft, 0),
        _buildCorner(Alignment.topRight, 1, flipX: true),
        _buildCorner(Alignment.bottomLeft, 2, flipY: true),
        _buildCorner(Alignment.bottomRight, 3, flipX: true, flipY: true),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment, int index, {bool flipX = false, bool flipY = false}) {
    return Positioned(
      top: alignment.y < 0 ? 24 : null,
      bottom: alignment.y > 0 ? 24 : null,
      left: alignment.x < 0 ? 24 : null,
      right: alignment.x > 0 ? 24 : null,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0),
        child: SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: _CornerPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildWordmark() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          fontFamily: 'Barlow Condensed',
        ),
        children: [
          TextSpan(text: 'FIT', style: TextStyle(color: AppColors.lime)),
          TextSpan(text: 'STRIKE', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'STRIKE YOUR FITNESS GOALS',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 4,
        color: Color(0xFF378ADD),
        fontFamily: 'DM Sans',
      ),
    );
  }

  Widget _buildProgressSection() {
    return SizedBox(
      width: 240,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.white.withValues(alpha: 0.3),
                  fontFamily: 'DM Sans',
                ),
              ),
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.lime,
                  fontFamily: 'Barlow Condensed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: widget.progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF378ADD), AppColors.lime],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lime.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildDots() {
    final activeDot = (widget.progress * 5).floor().clamp(0, 4);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isActive = index == activeDot;
        final isDone = index < activeDot;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
              ? AppColors.lime 
              : (isDone ? AppColors.lime.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1)),
            boxShadow: isActive ? [
              const BoxShadow(
                color: AppColors.lime,
                blurRadius: 8,
              ),
            ] : null,
          ),
        );
      }),
    );
  }

  Widget _buildBottomTag() {
    return Positioned(
      bottom: 40,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text(
          'OWN YOUR STREETS · V1.0.0',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            color: Colors.white.withValues(alpha: 0.12),
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF378ADD).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lime.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 40)
      ..lineTo(0, 0)
      ..lineTo(40, 0);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = AppColors.lime
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 3, dotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
