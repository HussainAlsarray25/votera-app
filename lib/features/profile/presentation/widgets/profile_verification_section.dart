import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Shown below the settings card on the profile page when the user is a visitor.
/// Displays the same verification method cards as VerifyAccountPage so the
/// user can start the verification flow without an extra navigation step.
class ProfileVerificationSection extends StatelessWidget {
  const ProfileVerificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Only show for unverified (visitor-only) users.
        if (state is! ProfileLoaded || !state.profile.isVisitorOnly) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;

        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.verifyAccount,
                style: AppTypography.labelMedium.copyWith(
                  color: context.colors.textHint,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              _buildCard(
                context: context,
                icon: Icons.school_outlined,
                title: l10n.student,
                subtitle: l10n.studentEmailExample,
                badge: l10n.instant,
                badgeColor: context.colors.success,
                onTap: () => context.push('/verify-account/email'),
              ),
              SizedBox(height: AppSpacing.md),
              _buildCard(
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
        );
      },
    );
  }

  Widget _buildCard({
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
