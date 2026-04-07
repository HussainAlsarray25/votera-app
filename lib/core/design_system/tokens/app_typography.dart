import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens built on top of Google Fonts (Inter).
///
/// Styles are intentionally colorless — they define font, size, weight,
/// and line-height only. Color is applied by each widget via:
///   style: AppTypography.h1.copyWith(color: context.colors.textPrimary)
///
/// Font sizes use ScreenUtil .sp so they scale with the device screen size
/// while still respecting the app-level text scaling clamp (0.8–1.2x).
class AppTypography {
  AppTypography._();

  static String get _fontFamily => GoogleFonts.inter().fontFamily!;

  // -- Headings --
  static TextStyle get h1 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // -- Body --
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  // -- Labels & Buttons --
  static TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get button => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // -- Caption --
  static TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );
}
