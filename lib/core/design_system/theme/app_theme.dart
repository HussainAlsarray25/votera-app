import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:votera/core/design_system/tokens/app_color_scheme.dart';
import 'package:votera/core/design_system/tokens/app_spacing.dart';

/// Builds Material 3 ThemeData for both light and dark modes.
///
/// Colors come from AppColorScheme, embedded as a ThemeExtension.
/// All component overrides are centralized here.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _build(AppColorScheme.dark, Brightness.dark);

  static ThemeData get lightTheme => _build(AppColorScheme.light, Brightness.light);

  static ThemeData _build(AppColorScheme colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.accent,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.textOnPrimary,
        onSecondary: colors.textOnPrimary,
        onSurface: colors.textPrimary,
        onError: colors.textOnPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.interTextTheme(
        // Seed the textTheme with the correct base brightness so Material's
        // default text colors start from the right contrast side.
        ThemeData(brightness: brightness).textTheme,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.cardBackground,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.error),
        ),
        hintStyle: TextStyle(color: colors.textHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        selectedIconTheme: IconThemeData(color: colors.primary),
        unselectedIconTheme: IconThemeData(color: colors.textHint),
        selectedLabelTextStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: colors.textHint),
      ),
      iconTheme: IconThemeData(color: colors.textSecondary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.cardBackground,
        selectedColor: colors.primary,
        labelStyle: TextStyle(color: colors.textPrimary),
        secondaryLabelStyle: TextStyle(color: colors.textOnPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
      ),
    );
  }
}
