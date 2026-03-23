import 'package:flutter/material.dart';

/// Centralized color tokens for the Votera design system.
/// Every color used in the app should come from here to ensure
/// visual consistency and easy theme updates.
///
/// Palette is inspired by Supabase's dark aesthetic:
/// near-black backgrounds with a signature green accent.
class AppColors {
  AppColors._();

  // -- Primary palette (Supabase signature green) --
  static const Color primary = Color(0xFF3ECF8E);
  static const Color primaryLight = Color(0xFF6ADBA8);
  static const Color primaryDark = Color(0xFF2AB578);

  // -- Secondary palette (blue, used for info and secondary actions) --
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF1D4ED8);

  // -- Accent (gold, retained for winner card highlight) --
  static const Color accent = Color(0xFFFBBF24);
  static const Color accentLight = Color(0xFFFDE68A);

  // -- Semantic colors --
  static const Color success = Color(0xFF3ECF8E); // matches primary green
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3B82F6);

  // -- Neutral / Background --
  static const Color background = Color(0xFF0F1117); // near-black base
  static const Color surface = Color(0xFF1C1C1C);    // elevated surface
  static const Color cardBackground = Color(0xFF171717);

  // -- Text --
  static const Color textPrimary = Color(0xFFEDEDED);   // off-white
  static const Color textSecondary = Color(0xFF9B9B9B); // medium gray
  static const Color textHint = Color(0xFF666666);       // muted
  static const Color textOnPrimary = Color(0xFF0F1117);  // dark on green

  // -- Borders & Dividers --
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF1F1F1F);

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
