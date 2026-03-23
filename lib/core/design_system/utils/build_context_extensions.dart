import 'package:flutter/material.dart';
import 'package:votera/core/design_system/tokens/app_color_scheme.dart';

/// Convenience extensions on BuildContext for design-system access.
extension AppDesignSystemX on BuildContext {
  /// Returns the current theme's color scheme.
  /// Reads from whichever ThemeData is active (light or dark).
  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;
}
