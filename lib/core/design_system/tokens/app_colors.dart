import 'package:flutter/material.dart';

/// Centralized color tokens for the Votera design system.
/// Every color used in the app should come from here to ensure
/// visual consistency and easy theme updates.
class AppColors {
  AppColors._();

  // -- Primary palette (green) --
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryDark = Color(0xFF16A34A);

  // -- Secondary palette (blue, used for info and secondary actions) --
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF1D4ED8);

  // -- Accent (gold, retained for winner card highlight) --
  static const Color accent = Color(0xFFFBBF24);
  static const Color accentLight = Color(0xFFFDE68A);

  // -- Semantic colors --
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3B82F6);

  // -- Neutral / Background --
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF121821);
  static const Color cardBackground = Color(0xFF151B26);

  // -- Text --
  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFF052E16);

  // -- Borders & Dividers --
  static const Color border = Color(0xFF1F2937);
  static const Color divider = Color(0xFF18202A);

  // -- Gradient: green to blue (used for buttons and headers) --
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -- Gradient: gold (used for winner cards) --
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
