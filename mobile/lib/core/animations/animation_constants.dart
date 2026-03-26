import 'package:flutter/animation.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration highlight = Duration(milliseconds: 600);

  // Transitions
  static const Duration pushDuration = Duration(milliseconds: 280);
  static const Duration popDuration = Duration(milliseconds: 240);
  static const Duration modalDuration = Duration(milliseconds: 360);
  static const Duration replaceDuration = Duration(milliseconds: 200);

  // Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOutQuad;
  static const Curve emphasize = Curves.elasticOut;
  static const Curve gameExit = Curves.easeInCubic;
  static const Curve bounce = Curves.bounceOut;

  // Spring Descriptions
  static const SpringDescription softSpring = SpringDescription(
    mass: 1.0,
    stiffness: 100.0,
    damping: 10.0,
  );

  static const SpringDescription tightSpring = SpringDescription(
    mass: 0.8,
    stiffness: 180.0,
    damping: 15.0,
  );
}
