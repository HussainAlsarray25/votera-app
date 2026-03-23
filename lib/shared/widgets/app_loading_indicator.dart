import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// An animated loading indicator with orbiting dots and a gradient "V" logo.
/// Use as a drop-in replacement for CircularProgressIndicator.
///
/// [size] controls the overall diameter (default 80).
/// [message] optionally shows a label below the indicator.
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 80,
    this.message,
  });

  final double size;
  final String? message;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _OrbitPainter(
                  progress: _controller.value,
                  primaryColor: context.colors.primary,
                  secondaryColor: context.colors.secondary,
                ),
                child: child,
              );
            },
            child: Center(
              child: _buildLogo(context),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.message!,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textHint,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    final logoSize = widget.size * 0.35;
    return ShaderMask(
      shaderCallback: (bounds) {
        return context.colors.primaryGradient.createShader(bounds);
      },
      child: Text(
        'V',
        style: TextStyle(
          fontSize: logoSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

/// Draws orbiting dots around a circular path.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  static const int _dotCount = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final angle = progress * 2 * math.pi;

    // Draw the faint track ring.
    final trackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw orbiting dots with staggered positions and fading opacity.
    for (var i = 0; i < _dotCount; i++) {
      final dotAngle = angle - (i * 0.55);
      final opacity = 1.0 - (i * 0.3);
      final dotRadius = 4.0 - (i * 0.8);

      final color = Color.lerp(primaryColor, secondaryColor, i / _dotCount)!;

      final dotPaint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.2, 1.0))
        ..style = PaintingStyle.fill;

      final dx = center.dx + radius * math.cos(dotAngle);
      final dy = center.dy + radius * math.sin(dotAngle);

      canvas.drawCircle(Offset(dx, dy), dotRadius.clamp(1.5, 4.0), dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
