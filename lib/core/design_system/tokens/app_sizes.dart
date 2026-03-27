import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive size tokens for icons and common widget dimensions.
///
/// Uses ScreenUtil extensions so values scale proportionally across
/// all screen sizes. Use `.r` for square elements (icons, avatars) and
/// `.h` for directional heights (images, buttons).
class AppSizes {
  AppSizes._();

  // -- Icon sizes --
  // Use .r (radius) so icons scale based on the smaller screen axis,
  // keeping them proportional on both phones and tablets.
  static double get iconXs => 12.r; // tiny indicators, pull-to-refresh hints
  static double get iconSm => 16.r; // verified badge, small label icons
  static double get iconMd => 20.r; // standard action icons, text field prefix
  static double get iconLg => 24.r; // general UI icons, error state icons
  static double get iconXl => 36.r; // large action icons, star ratings
  static double get iconXxl => 48.r; // empty state and full-page error icons

  // -- Avatar / profile image sizes --
  static double get avatarSm => 32.r;
  static double get avatarMd => 40.r;
  static double get avatarLg => 56.r;

  // -- Common widget dimensions --
  static double get cardImageHeight => 160.h; // ProjectCard thumbnail
  static double get shimmerImageHeight => 140.h; // ShimmerCard placeholder
  static double get buttonHeight => 52.h; // GradientButton default height
  static double get emptyStateBubbleOuter => 130.r; // EmptyState outer circle
  static double get emptyStateBubbleInner => 88.r; // EmptyState inner circle
  static double get emptyStateIconSize => 40.r; // Icon inside EmptyState bubble
  static double get emptyStatePullHintIcon => 14.r; // Arrow down pull hint icon
}
