import 'dart:async';

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// A reusable empty state widget displayed when there
/// is no data to show (e.g. no events, no notifications).
/// Features a gentle floating animation on the icon to draw attention.
/// Shows a "pull down to refresh" hint at the bottom.
class EmptyState extends StatefulWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showRefreshHint = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showRefreshHint;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Gentle up-down floating motion.
    _float = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fade in on first appearance.
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedIcon(context),
            SizedBox(height: AppSpacing.lg),
            Text(
              widget.title,
              style: AppTypography.h3.copyWith(
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                widget.subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textHint,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.showRefreshHint) ...[
              SizedBox(height: AppSpacing.xl),
              _buildPullHint(context),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        );
      },
      child: _buildIconBubble(context),
    );
  }

  Widget _buildIconBubble(BuildContext context) {
    return Container(
      width: AppSizes.emptyStateBubbleOuter,
      height: AppSizes.emptyStateBubbleOuter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.06),
            context.colors.secondary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: AppSizes.emptyStateBubbleInner,
          height: AppSizes.emptyStateBubbleInner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.12),
                context.colors.secondary.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return context.colors.primaryGradient.createShader(bounds);
              },
              child: Icon(
                widget.icon,
                size: AppSizes.emptyStateIconSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A subtle hint telling the user they can swipe down to refresh.
  Widget _buildPullHint(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_downward_rounded,
          size: AppSizes.emptyStatePullHintIcon,
          color: context.colors.textHint.withValues(alpha: 0.6),
        ),
        SizedBox(width: AppSpacing.xs + 2),
        Text(
          AppLocalizations.of(context)!.pullToRefresh,
          style: AppTypography.caption.copyWith(
            color: context.colors.textHint.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
