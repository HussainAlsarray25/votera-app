import 'dart:async';

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// An interactive star rating widget with glow and bounce animation.
/// Stars animate individually when the user taps a rating value.
///
/// Omit [size] to use the default responsive size (AppSizes.iconXl).
class AnimatedStarRating extends StatefulWidget {
  const AnimatedStarRating({
    this.rating = 0,
    this.maxRating = 5,
    this.size,
    this.onRatingChanged,
    this.isInteractive = true,
    super.key,
  });

  final int rating;
  final int maxRating;
  // Nullable so the widget can resolve the default via AppSizes at build time.
  final double? size;
  final ValueChanged<int>? onRatingChanged;
  final bool isInteractive;

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating>
    with TickerProviderStateMixin {
  late int _currentRating;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.maxRating,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1, end: 1.3), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 1), weight: 50),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();
  }

  @override
  void didUpdateWidget(AnimatedStarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _currentRating = widget.rating;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    if (!widget.isInteractive) return;

    setState(() => _currentRating = index + 1);

    // Animate each filled star with a staggered delay
    for (var i = 0; i <= index; i++) {
      unawaited(
        Future.delayed(Duration(milliseconds: i * 60), () async {
          if (mounted) await _controllers[i].forward(from: 0);
        }),
      );
    }

    widget.onRatingChanged?.call(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    // Resolve the effective size at build time so AppSizes can access ScreenUtil.
    final effectiveSize = widget.size ?? AppSizes.iconXl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final isFilled = index < _currentRating;

        return GestureDetector(
          onTap: () => _handleTap(index),
          child: AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: effectiveSize,
                color: isFilled
                    ? context.colors.accent
                    : context.colors.textHint,
                shadows: isFilled
                    ? [
                        Shadow(
                          color: context.colors.accent.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
