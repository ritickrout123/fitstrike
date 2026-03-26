import 'package:flutter/material.dart';

import '../../config/theme.dart';

class AppViewport extends StatelessWidget {
  const AppViewport({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isFramed = constraints.maxWidth >= 560;
        final radius = isFramed ? 32.0 : 0.0;

        final content = ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                  color:
                      isFramed ? AppColors.borderStrong : Colors.transparent),
              boxShadow: isFramed
                  ? const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 40,
                        offset: Offset(0, 24),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                Color(0xFF161C2C),
                Color(0xFF06070B),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x26C8FF00),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x1A00E5FF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isFramed ? 24 : 0,
                    vertical: isFramed ? 20 : 0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
