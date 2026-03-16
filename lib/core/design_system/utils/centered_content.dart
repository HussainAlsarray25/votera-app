import 'package:flutter/material.dart';
import 'package:votera/core/design_system/utils/app_breakpoints.dart';

/// Constrains and centers its child on wide screens.
/// On mobile, passes the child through without wrapping.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    required this.child,
    this.maxWidth = AppBreakpoints.desktopContentMax,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
