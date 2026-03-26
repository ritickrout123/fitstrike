import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/animations/animation_constants.dart';
import '../../../../config/theme.dart';

class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({
    super.key,
    required this.level,
    required this.onDismiss,
  });

  final int level;
  final VoidCallback onDismiss;

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _glitchController;
  late final AnimationController _xpBarController;
  
  bool _showPerks = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _xpBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _entryController.forward();
    _glitchController.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 300));
    await _xpBarController.forward();
    setState(() => _showPerks = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    _glitchController.stop();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glitchController.dispose();
    _xpBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.94),
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lime.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Particles (Simplified for this widget)
          ...List.generate(30, (index) => _FallingParticle()),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "LEVEL UP" with Glitch
                AnimatedBuilder(
                  animation: _glitchController,
                  builder: (context, child) {
                    final offset = _glitchController.value * 5.0;
                    return Stack(
                      children: [
                        Transform.translate(
                          offset: Offset(-offset, 0),
                          child: Text(
                            'LEVEL UP',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppColors.cyan.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Barlow Condensed',
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(offset, 0),
                          child: Text(
                            'LEVEL UP',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppColors.rose.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Barlow Condensed',
                            ),
                          ),
                        ),
                        Text(
                          'LEVEL UP',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Barlow Condensed',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 10),
                
                // Big Level Number
                ScaleTransition(
                  scale: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
                  ),
                  child: Text(
                    '${widget.level}',
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lime,
                      height: 1,
                      shadows: [
                        Shadow(color: AppColors.lime.withValues(alpha: 0.5), blurRadius: 40),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Progress Bar
                Container(
                  width: 280,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AnimatedBuilder(
                    animation: _xpBarController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _xpBarController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.cyan, AppColors.lime],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: AppColors.lime.withValues(alpha: 0.5), blurRadius: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Perks
                if (_showPerks)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PerkBadge(icon: Icons.flash_on_rounded, label: 'Energy +5%'),
                      const SizedBox(width: 20),
                      _PerkBadge(icon: Icons.shield_rounded, label: 'Defense +2%'),
                    ],
                  ),
                
                const SizedBox(height: 60),
                
                // Dismiss Button
                FadeTransition(
                  opacity: _entryController,
                  child: FilledButton(
                    onPressed: widget.onDismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text('CONTINUE STRIKE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerkBadge extends StatelessWidget {
  const _PerkBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.lime),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FallingParticle extends StatefulWidget {
  @override
  State<_FallingParticle> createState() => _FallingParticleState();
}

class _FallingParticleState extends State<_FallingParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _startX;
  late final double _speed;
  late final Color _color;

  @override
  void initState() {
    super.initState();
    _startX = math.Random().nextDouble();
    _speed = 0.5 + math.Random().nextDouble();
    _color = math.Random().nextBool() ? AppColors.lime : AppColors.cyan;
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + math.Random().nextInt(1500)),
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
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        return Positioned(
          left: _startX * screenWidth,
          top: (_controller.value * screenHeight * 1.5) - 100,
          child: Opacity(
            opacity: math.sin(_controller.value * math.pi),
            child: Container(
              width: 3,
              height: 10,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}
