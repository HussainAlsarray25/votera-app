import 'package:flutter/material.dart';

/// Centralized color tokens for the Votera design system.
/// Every color used in the app should come from here to ensure
/// visual consistency and easy theme updates.
class AppColors {
  AppColors._();

  // -- Primary palette --
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // -- Secondary palette --
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFC4B5FD);
  static const Color secondaryDark = Color(0xFF6D28D9);

  // -- Accent --
  static const Color accent = Color(0xFFFBBF24);
  static const Color accentLight = Color(0xFFFDE68A);

  // -- Semantic colors --
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // -- Neutral / Background --
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // -- Text --
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // -- Borders & Dividers --
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // -- Gradient used across the app for buttons and headers --
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
