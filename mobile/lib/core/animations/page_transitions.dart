import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'animation_constants.dart';

class AppTransitions {
  static CustomTransitionPage<T> slideUp<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.pushDuration,
      reverseTransitionDuration: AppAnimations.popDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08), // 40px estimated at 0.08 of screen height
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppAnimations.standard,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> crossFadeScale<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.replaceDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: AppAnimations.standard),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> modalSpring<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.modalDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppAnimations.emphasize,
          )),
          child: child,
        );
      },
    );
  }
}
