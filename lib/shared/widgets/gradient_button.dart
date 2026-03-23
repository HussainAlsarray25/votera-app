import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A reusable button with a gradient background and optional loading state.
/// Used for primary actions throughout the app (login, vote, submit).
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height = 52,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Fall back to the theme's primary gradient if no custom gradient is provided.
    final effectiveGradient = gradient ?? context.colors.primaryGradient;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null ? effectiveGradient : null,
        color: onPressed == null ? context.colors.border : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: onPressed != null ? AppShadows.button : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textOnPrimary,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: AppTypography.button.copyWith(
                      color: context.colors.textOnPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
