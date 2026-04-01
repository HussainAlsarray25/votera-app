import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

// =============================================================================
// Public API — call these from anywhere in the app
// =============================================================================

/// Shows a confirmation dialog and returns [true] if the user confirms,
/// [false] if they cancel, and [null] if the dialog is dismissed.
///
/// Set [isDestructive] to [true] for actions like delete or remove — the
/// confirm button will use the error color to signal danger.
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    ),
  );
}

/// Shows an input dialog with a single text field and returns the trimmed
/// input string if the user confirms, or [null] if they cancel.
Future<String?> showAppInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
  String? cancelLabel,
  String? initialValue,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => AppInputDialog(
      title: title,
      hint: hint,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
    ),
  );
}

// =============================================================================
// AppConfirmDialog
// =============================================================================

/// A themed confirmation dialog with cancel and confirm actions.
///
/// Use [showAppConfirmDialog] to display it — do not push directly via
/// Navigator unless you need fine-grained control over the route.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;

  /// Defaults to the localised "Cancel" string if omitted.
  final String? cancelLabel;

  /// When true the confirm button uses the error colour instead of primary.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Use the provided label or fall back to the Material default cancel label.
    final effectiveCancelLabel =
        cancelLabel ?? MaterialLocalizations.of(context).cancelButtonLabel;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              title,
              style: AppTypography.h3.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.sm),
            // Message
            Text(
              message,
              style:
                  AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: AppSpacing.xl),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: _CancelButton(label: effectiveCancelLabel)),
                SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: _ConfirmButton(
                    label: confirmLabel,
                    isDestructive: isDestructive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// AppInputDialog
// =============================================================================

/// A themed dialog with a single text input field.
///
/// Use [showAppInputDialog] to display it.
class AppInputDialog extends StatefulWidget {
  const AppInputDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    this.cancelLabel,
    this.initialValue,
    super.key,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String? cancelLabel;
  final String? initialValue;

  @override
  State<AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<AppInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveCancelLabel =
        widget.cancelLabel ?? MaterialLocalizations.of(context).cancelButtonLabel;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              widget.title,
              style: AppTypography.h3.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.md),
            // Input field
            TextField(
              controller: _controller,
              autofocus: true,
              style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                    AppTypography.bodyMedium.copyWith(color: colors.textHint),
                filled: true,
                fillColor: colors.cardBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
              onSubmitted: (_) =>
                  Navigator.of(context).pop(_controller.text.trim()),
            ),
            SizedBox(height: AppSpacing.xl),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _CancelButton(label: effectiveCancelLabel),
                SizedBox(width: AppSpacing.sm),
                _ConfirmButton(
                  label: widget.confirmLabel,
                  onPressed: () =>
                      Navigator.of(context).pop(_controller.text.trim()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Private button helpers
// =============================================================================

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        foregroundColor: colors.textSecondary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: colors.border),
        ),
      ),
      child: Text(label, style: AppTypography.labelMedium),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    this.isDestructive = false,
    this.onPressed,
  });

  final String label;
  final bool isDestructive;

  // When null the button pops true — used by AppConfirmDialog.
  // AppInputDialog passes its own callback to pop the input value instead.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveOnPressed =
        onPressed ?? () => Navigator.of(context).pop(true);
    final foreground =
        isDestructive ? Colors.white : colors.textOnPrimary;
    final background = isDestructive ? colors.error : colors.primary;

    return TextButton(
      onPressed: effectiveOnPressed,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(color: foreground),
      ),
    );
  }
}