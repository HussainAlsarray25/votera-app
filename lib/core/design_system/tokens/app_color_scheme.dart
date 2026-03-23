import 'package:flutter/material.dart';

/// Runtime color scheme for the Votera design system.
///
/// Implements Flutter's ThemeExtension so both light and dark palettes
/// can live inside their respective ThemeData objects and switch
/// automatically when the user changes the theme mode.
///
/// Access colors in widgets via:
///   context.colors.primary
///   context.colors.background
///   etc.
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.accent,
    required this.accentLight,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textOnPrimary,
    required this.border,
    required this.divider,
  });

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color accent;
  final Color accentLight;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textOnPrimary;
  final Color border;
  final Color divider;

  // Computed gradient from primary to secondary — adapts per theme.
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Gold gradient is palette-independent and therefore constant.
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -- Dark palette: Supabase-inspired near-black with green accent --
  static const AppColorScheme dark = AppColorScheme(
    primary: Color(0xFF3ECF8E),
    primaryLight: Color(0xFF6ADBA8),
    primaryDark: Color(0xFF2AB578),
    secondary: Color(0xFF3B82F6),
    secondaryLight: Color(0xFF60A5FA),
    secondaryDark: Color(0xFF1D4ED8),
    accent: Color(0xFFFBBF24),
    accentLight: Color(0xFFFDE68A),
    success: Color(0xFF3ECF8E),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF3B82F6),
    background: Color(0xFF0F1117),
    surface: Color(0xFF1C1C1C),
    cardBackground: Color(0xFF171717),
    textPrimary: Color(0xFFEDEDED),
    textSecondary: Color(0xFF9B9B9B),
    textHint: Color(0xFF666666),
    textOnPrimary: Color(0xFF0F1117),
    border: Color(0xFF2A2A2A),
    divider: Color(0xFF1F1F1F),
  );

  // -- Light palette: clean white surfaces with green accent --
  static const AppColorScheme light = AppColorScheme(
    primary: Color(0xFF3ECF8E),
    primaryLight: Color(0xFF6ADBA8),
    primaryDark: Color(0xFF2AB578),
    secondary: Color(0xFF3B82F6),
    secondaryLight: Color(0xFF60A5FA),
    secondaryDark: Color(0xFF1D4ED8),
    accent: Color(0xFFFBBF24),
    accentLight: Color(0xFFFDE68A),
    success: Color(0xFF3ECF8E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textHint: Color(0xFF9CA3AF),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFF3F4F6),
  );

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryDark,
    Color? accent,
    Color? accentLight,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textOnPrimary,
    Color? border,
    Color? divider,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryDark: Color.lerp(secondaryDark, other.secondaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
