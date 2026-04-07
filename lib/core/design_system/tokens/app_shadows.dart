import 'package:flutter/material.dart';

/// Shadow and glow presets for cards, buttons, and elevated surfaces.
///
/// On dark backgrounds, traditional drop shadows are nearly invisible.
/// Card and button shadows are replaced with deeper blacks or green glows
/// that read clearly against the dark surface palette.
class AppShadows {
  AppShadows._();

  // Card elevation — adapts to theme brightness.
  // Dark mode uses a strong black shadow for visibility on dark surfaces.
  // Light mode uses a subtle shadow so it doesn't look too heavy on white.
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // Hover/focus state — subtle green glow to indicate interactivity.
  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: const Color(0xFF3ECF8E).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // Primary action button — green tinted glow matching the accent color.
  static List<BoxShadow> get button => [
        BoxShadow(
          color: const Color(0xFF3ECF8E).withValues(alpha: 0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  // Golden glow used for winner project cards — unchanged.
  static List<BoxShadow> get goldenGlow => [
        BoxShadow(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
}
