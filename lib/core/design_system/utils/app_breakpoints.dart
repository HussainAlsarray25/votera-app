import 'package:flutter/material.dart';
import 'package:votera/core/design_system/utils/real_viewport.dart';

/// Screen-width breakpoints for responsive layout decisions.
/// Mobile < 600, Tablet 600-1024, Desktop > 1024.
///
/// All methods read from [RealViewport] instead of [MediaQuery] because the
/// app clamps MediaQuery to a max of 375px for ScreenUtil token scaling.
/// Without this, every breakpoint check would always return isMobile=true.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  // Maximum content widths for constraining layouts on wide screens
  static const double desktopContentMax = 1200;
  static const double formPanelMax = 480;

  static bool isMobile(BuildContext context) {
    return RealViewport.sizeOf(context).width < mobileMax;
  }

  static bool isTablet(BuildContext context) {
    final width = RealViewport.sizeOf(context).width;
    return width >= mobileMax && width <= tabletMax;
  }

  static bool isDesktop(BuildContext context) {
    return RealViewport.sizeOf(context).width > tabletMax;
  }

  /// Returns the number of columns for project grids:
  /// 1 on mobile, 2 on tablet, 3 on desktop.
  static int projectGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Whether to show NavigationRail instead of BottomNavigationBar.
  static bool useNavigationRail(BuildContext context) {
    return !isMobile(context);
  }
}
