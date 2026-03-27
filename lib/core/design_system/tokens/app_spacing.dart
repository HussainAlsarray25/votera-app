import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Consistent spacing tokens used throughout the app.
///
/// Uses ScreenUtil so spacing scales proportionally across screen sizes.
/// Values are based on a 4px grid (design reference: 375x812).
/// All tokens are getters (not const) because ScreenUtil resolves at runtime.
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 16.r;
  static double get lg => 24.r;
  static double get xl => 32.r;
  static double get xxl => 48.r;

  // Padding presets for common use
  static EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get cardPadding => EdgeInsets.all(md);
  static EdgeInsets get sectionPadding => EdgeInsets.symmetric(vertical: lg);

  // Border radius presets
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 24.r;
  static double get radiusFull => 100.r;
}
