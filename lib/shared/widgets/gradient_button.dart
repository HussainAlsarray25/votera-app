import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A reusable button with a solid primary color background and optional loading state.
/// Used for primary actions throughout the app (login, vote, submit).
///
/// Omit [height] to use the default responsive height (AppSizes.buttonHeight).
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  // Nullable so the widget resolves the default via AppSizes at build time.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? AppSizes.buttonHeight;

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: onPressed != null ? context.colors.primary : context.colors.border,
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
                    height: AppSizes.iconLg,
                    width: AppSizes.iconLg,
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
