import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A small gold verified icon used next to professor-verified authors.
///
/// Omit [size] to use the default responsive size (AppSizes.iconSm).
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({this.size, super.key});

  // Nullable so the widget resolves the default via AppSizes at build time.
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size ?? AppSizes.iconSm,
      color: context.colors.accent,
    );
  }
}
