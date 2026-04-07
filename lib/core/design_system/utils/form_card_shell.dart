import 'package:flutter/material.dart';
import 'package:votera/core/design_system/tokens/app_shadows.dart';
import 'package:votera/core/design_system/tokens/app_spacing.dart';
import 'package:votera/core/design_system/utils/app_breakpoints.dart';
import 'package:votera/core/design_system/utils/build_context_extensions.dart';

/// Wraps form page body content with the appropriate visual treatment per
/// viewport size.
///
/// - Mobile (<600px): full-screen scrollable layout with page padding.
/// - Tablet/Desktop (>=600px): the form is presented inside a floating card
///   centered over the page background, with a scroll area around it.
///
/// Usage: place as the direct body (or inside a BlocListener body) of a
/// Scaffold. Pass only the form content column as [child] — FormCardShell
/// handles SafeArea, scroll, and padding internally.
///
/// Example:
/// ```dart
/// Scaffold(
///   appBar: ...,
///   body: BlocListener(
///     child: FormCardShell(child: Column(...)),
///   ),
/// )
/// ```
class FormCardShell extends StatelessWidget {
  const FormCardShell({required this.child, super.key});

  final Widget child;

  // Maximum width of the floating form card on non-mobile viewports.
  static const double _cardMaxWidth = 520.0;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: child,
        ),
      );
    }

    // On tablet and desktop: center a floating card over the page background.
    // The card provides visual separation from the background and focuses
    // attention on the form, regardless of how wide the viewport is.
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xxl,
              horizontal: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: context.colors.border),
                  boxShadow: AppShadows.card(Theme.of(context).brightness),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
