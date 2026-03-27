import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Entry point for account verification. Shows two method cards — one for
/// students (participant email OTP) and one for professors/supervisors
/// (supervisor email OTP) — so the user picks the path that matches their role.
class VerifyAccountPage extends StatelessWidget {
  const VerifyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          l10n.verifyAccount,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CenteredContent(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.lg),
                _buildHeader(context, l10n),
                SizedBox(height: AppSpacing.xxl),
                _buildMethodCard(
                  context: context,
                  icon: Icons.school_outlined,
                  title: l10n.student,
                  subtitle: l10n.studentEmailExample,
                  badge: l10n.instant,
                  badgeColor: context.colors.success,
                  onTap: () => context.push('/verify-account/email'),
                ),
                SizedBox(height: AppSpacing.md),
                _buildMethodCard(
                  context: context,
                  icon: Icons.person_outlined,
                  title: l10n.professor,
                  subtitle: l10n.teacherEmailExample,
                  badge: l10n.instant,
                  badgeColor: context.colors.primary,
                  onTap: () => context.push('/verify-account/supervisor-email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.chooseVerificationMethod,
          style: AppTypography.h1.copyWith(
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.verificationUnlocks,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
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
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.card(Theme.of(context).brightness),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: badgeColor, size: AppSizes.iconLg),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.labelLarge.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
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
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textHint),
          ],
        ),
      ),
    );
  }
}
