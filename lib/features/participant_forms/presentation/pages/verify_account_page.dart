import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Entry point for account verification. Shows two method cards:
/// institutional email (immediate) and university ID card (admin review).
class VerifyAccountPage extends StatelessWidget {
  const VerifyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: Text('Verify Account', style: AppTypography.labelLarge),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                _buildHeader(),
                const SizedBox(height: AppSpacing.xxl),
                _buildMethodCard(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Institutional Email',
                  subtitle: 'Verify with your university email address.\n'
                      'You will receive a 6-digit OTP instantly.',
                  badge: 'Instant',
                  badgeColor: AppColors.success,
                  onTap: () => context.push('/verify-account/email'),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildMethodCard(
                  context: context,
                  icon: Icons.badge_outlined,
                  title: 'University ID Card',
                  subtitle: 'Upload a photo of your university ID card.\n'
                      'An admin will review your request.',
                  badge: 'Requires Review',
                  badgeColor: AppColors.warning,
                  onTap: () => context.push('/verify-account/uid'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Choose Verification Method',
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Verifying your account unlocks full access to all features.',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: AppTypography.caption.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
