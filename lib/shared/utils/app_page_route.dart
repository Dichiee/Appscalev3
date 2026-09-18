import 'package:flutter/material.dart';

/// Standard forward-navigation transition for the whole app — slide in
/// from the right with a light fade, replacing Flutter's default
/// zoom/fade-through transition on Android, which can read as a plain
/// fade rather than a deliberate push. Use this everywhere instead of
/// a bare MaterialPageRoute for consistent feel across every screen.
Route<T> appPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .animate(animation);
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
    },
  );
}