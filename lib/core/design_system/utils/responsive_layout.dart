import 'package:flutter/material.dart';
import 'package:votera/core/design_system/utils/app_breakpoints.dart';

/// Renders different widget trees based on screen width tier.
/// Falls back to the next smaller tier if a builder is null:
/// desktop -> tablet -> mobile.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (AppBreakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
