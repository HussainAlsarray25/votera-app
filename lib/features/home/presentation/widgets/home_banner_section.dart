import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Announcement banner displayed below the search bar.
/// Shows a greeting and highlights the current event (e.g. hackathon voting).
class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildEmojiBox(),
          const SizedBox(width: 14),
          Expanded(child: _buildText(context)),
        ],
      ),
    );
  }

  Widget _buildEmojiBox() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
      ),
      child: const Center(
        child: Text('\u{1F44B}', style: TextStyle(fontSize: 28)),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.heyThere,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        RichText(
          text: TextSpan(
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
            children: [
              TextSpan(text: l10n.thePrefix),
              TextSpan(
                text: l10n.springHackathon,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const TextSpan(
                text: ' voting is live. Have you picked your favorite yet?',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
