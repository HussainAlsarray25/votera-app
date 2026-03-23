import 'dart:async';

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A shimmer placeholder that mimics loading content.
/// Wrap any widget shape to show a skeleton pulse effect.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme-aware surface and border colors so the shimmer adapts to
    // both light and dark modes.
    final baseColor = context.colors.surface;
    final highlightColor = context.colors.border;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pre-built skeleton shapes for common loading patterns.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Title placeholder
            Container(
              height: 16,
              width: 180,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Subtitle placeholder
            Container(
              height: 12,
              width: 120,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
