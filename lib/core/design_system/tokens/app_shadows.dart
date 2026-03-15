import 'package:flutter/material.dart';

/// Soft shadow presets for cards, buttons, and elevated surfaces.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // Golden glow used for winner project cards
  static List<BoxShadow> get goldenGlow => [
        BoxShadow(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
}
