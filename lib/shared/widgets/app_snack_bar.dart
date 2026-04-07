import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

// =============================================================================
// Public API — call these from anywhere in the app
// =============================================================================

/// Snackbar severity — controls background color and icon.
enum AppSnackBarType { info, success, error }

/// Shows a themed floating snackbar.
///
/// [type] controls the appearance:
/// - [AppSnackBarType.info]    — surface background, primary border (default)
/// - [AppSnackBarType.success] — success color background
/// - [AppSnackBarType.error]   — error color background
///
/// Pass [action] for an optional label/callback button inside the snackbar.
///
/// Usage:
/// ```dart
/// showAppSnackBar(context, 'Profile updated', type: AppSnackBarType.success);
/// showAppSnackBar(context, state.message, type: AppSnackBarType.error);
/// ```
void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarType type = AppSnackBarType.info,
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      _buildSnackBar(
        context: context,
        message: message,
        type: type,
        action: action,
        duration: duration,
      ),
    );
}

// =============================================================================
// Builder — private
// =============================================================================

SnackBar _buildSnackBar({
  required BuildContext context,
  required String message,
  required AppSnackBarType type,
  required SnackBarAction? action,
  required Duration duration,
}) {
  final colors = context.colors;

  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final IconData iconData;

  switch (type) {
    case AppSnackBarType.success:
      backgroundColor = colors.success;
      textColor = Colors.white;
      borderColor = null;
      iconData = Icons.check_circle_outline_rounded;
    case AppSnackBarType.error:
      backgroundColor = colors.error;
      textColor = Colors.white;
      borderColor = null;
      iconData = Icons.error_outline_rounded;
    case AppSnackBarType.info:
      backgroundColor = colors.surface;
      textColor = colors.textPrimary;
      borderColor = colors.border;
      iconData = Icons.info_outline_rounded;
  }

  return SnackBar(
    duration: duration,
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      side: borderColor != null
          ? BorderSide(color: borderColor)
          : BorderSide.none,
    ),
    action: action != null
        ? SnackBarAction(
            label: action.label,
            textColor: textColor,
            onPressed: action.onPressed,
          )
        : null,
    content: Row(
      children: [
        Icon(iconData, color: textColor, size: AppSizes.iconMd),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: textColor),
          ),
        ),
      ],
    ),
  );
}
