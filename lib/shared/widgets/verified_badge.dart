import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A small gold star icon used next to professor-verified authors.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({this.size = 16, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size,
      color: context.colors.accent,
    );
  }
}
