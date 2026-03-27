import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// A horizontal list of projects the current user has voted for.
class ProfileVotedProjectsSection extends StatelessWidget {
  const ProfileVotedProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            AppLocalizations.of(context)!.yourVotes,
            style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pagePadding,
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
            itemBuilder: _buildVotedCard,
          ),
        ),
      ],
    );
  }

  Widget _buildVotedCard(BuildContext context, int index) {
    final names = ['Smart Campus', 'AI Tutor', 'EcoTrack', 'MedAssist'];
    final colors = [
      context.colors.primary,
      context.colors.secondary,
      context.colors.success,
      context.colors.accent,
    ];

    return Container(
      width: 140.w,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors[index].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors[index].withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code, color: colors[index], size: AppSizes.iconMd),
          const Spacer(),
          Text(
            names[index],
            style: AppTypography.labelMedium.copyWith(color: colors[index]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            AppLocalizations.of(context)!.voted,
            style: AppTypography.caption.copyWith(
              color: context.colors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
