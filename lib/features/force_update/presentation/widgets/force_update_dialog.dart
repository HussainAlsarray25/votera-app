import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// The non-dismissible dialog shown when a force update is required.
///
/// Displays a gradient icon header, the new version name, server-provided
/// localized message, and a full-width gradient download button.
class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({
    required this.updateUrl,
    required this.latestVersionName,
    required this.messageEn,
    required this.messageAr,
    super.key,
  });

  final String updateUrl;
  final String latestVersionName;
  final String messageEn;
  final String messageAr;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Use the server-provided message for the current locale.
    // Fall back to the other language if the preferred one is empty.
    final message = isArabic
        ? (messageAr.isNotEmpty ? messageAr : messageEn)
        : (messageEn.isNotEmpty ? messageEn : messageAr);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: colors.border),
      ),
      // Constrain width on larger viewports so it doesn't stretch too wide.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GradientHeader(colors: colors),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    l10n.forceUpdateTitle,
                    style: AppTypography.h3.copyWith(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  // Version badge — only shown if the server provides a name.
                  if (latestVersionName.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.sm),
                    _VersionBadge(
                      versionName: latestVersionName,
                      colors: colors,
                    ),
                  ],
                  // Server message
                  if (message.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: AppSpacing.xl),
                  // Download button
                  GradientButton(
                    text: l10n.forceUpdateButton,
                    onPressed: () => _openUpdateUrl(updateUrl),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUpdateUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception catch (_) {
      // If launching fails, the user can try again by tapping the button again.
    }
  }
}

// -----------------------------------------------------------------------------
// Gradient header with the update icon
// -----------------------------------------------------------------------------

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.system_update_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Version name badge
// -----------------------------------------------------------------------------

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({
    required this.versionName,
    required this.colors,
  });

  final String versionName;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: colors.primary.withOpacity(0.3)),
        ),
        child: Text(
          'v$versionName',
          style: AppTypography.labelMedium.copyWith(color: colors.primary),
        ),
      ),
    );
  }
}
