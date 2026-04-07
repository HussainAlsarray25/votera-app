import 'dart:async';

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// A reusable failure state widget displayed when a data load has failed.
/// Mirrors the visual structure of [EmptyState] but uses error color
/// theming to communicate that something went wrong.
/// Shows an icon bubble, a title, a message, and a retry button.
class FailureState extends StatefulWidget {
  const FailureState({
    required this.message,
    required this.onRetry,
    this.title,
    this.icon = Icons.error_outline,
    super.key,
  });

  /// The error message to display below the title.
  final String message;

  /// Called when the user taps the retry button.
  final VoidCallback onRetry;

  /// Optional override for the title. Defaults to the localized
  /// "Something went wrong" string.
  final String? title;

  /// Icon to show inside the bubble. Defaults to [Icons.error_outline].
  final IconData icon;

  @override
  State<FailureState> createState() => _FailureStateState();
}

class _FailureStateState extends State<FailureState>
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

    // Gentle up-down floating motion — same cadence as EmptyState.
    _float = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fade in during the first 40% of the animation cycle.
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
    final l10n = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: _fade,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedIcon(context),
              SizedBox(height: AppSpacing.lg),
              Text(
                widget.title ?? l10n.somethingWentWrong,
                style: AppTypography.h3.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  widget.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textHint,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: widget.onRetry,
                child: Text(l10n.retry),
              ),
            ],
          ),
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
    // Use the error color for the bubble gradient to clearly signal a failure,
    // as opposed to EmptyState which uses the primary/secondary brand colors.
    final errorColor = context.colors.error;

    return Container(
      width: AppSizes.emptyStateBubbleOuter,
      height: AppSizes.emptyStateBubbleOuter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            errorColor.withValues(alpha: 0.06),
            errorColor.withValues(alpha: 0.04),
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
                errorColor.withValues(alpha: 0.14),
                errorColor.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: errorColor.withValues(alpha: 0.10),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: AppSizes.emptyStateIconSize,
              color: errorColor,
            ),
          ),
        ),
      ),
    );
  }
}
