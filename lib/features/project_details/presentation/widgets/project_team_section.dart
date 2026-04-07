import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/project_details/presentation/cubit/project_team_cubit.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';

/// Displays the team name, image, and member list for a project.
/// Triggers the team fetch once the project is confirmed loaded.
class ProjectTeamSection extends StatefulWidget {
  const ProjectTeamSection({super.key});

  @override
  State<ProjectTeamSection> createState() => _ProjectTeamSectionState();
}

class _ProjectTeamSectionState extends State<ProjectTeamSection> {
  @override
  void initState() {
    super.initState();
    // The parent BlocBuilder guarantees ProjectDetailLoaded at this point.
    final projectState = context.read<ProjectsCubit>().state;
    if (projectState is ProjectDetailLoaded) {
      context.read<ProjectTeamCubit>().loadTeam(projectState.project.teamId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProjectTeamCubit, ProjectTeamState>(
      builder: (context, state) {
        if (state is ProjectTeamInitial || state is ProjectTeamLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is ProjectTeamError || state is! ProjectTeamLoaded) {
          return const SizedBox.shrink();
        }

        return _buildCard(context, l10n, state.team);
      },
    );
  }

  Widget _buildCard(BuildContext context, AppLocalizations l10n, TeamEntity team) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n, team),
          SizedBox(height: AppSpacing.md),
          _buildMemberList(context, team),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, TeamEntity team) {
    return Row(
      children: [
        Icon(Icons.group_outlined, size: AppSizes.iconSm, color: context.colors.primary),
        SizedBox(width: 6.w),
        Text(
          l10n.projectTeam,
          style: AppTypography.labelLarge.copyWith(color: context.colors.textPrimary),
        ),
        const Spacer(),
        _TeamAvatar(imageUrl: team.imageUrl, name: team.name, size: 28.r),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            team.name,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberList(BuildContext context, TeamEntity team) {
    if (team.members.isEmpty) return const SizedBox.shrink();

    return Column(
      children: team.members
          .map((member) => _MemberRow(
                member: member,
                isLeader: member.userId == team.leaderId,
              ))
          .toList(),
    );
  }
}

// -- Circular avatar for the team image --
class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({
    required this.imageUrl,
    required this.name,
    required this.size,
  });

  final String? imageUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primary.withValues(alpha: 0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitial(context, initial),
            )
          : _buildInitial(context, initial),
    );
  }

  Widget _buildInitial(BuildContext context, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
      ),
    );
  }
}

// -- Single member row with avatar, name, and optional leader badge --
class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.isLeader});

  final TeamMemberEntity member;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = member.profilePictureUrl != null &&
        member.profilePictureUrl!.isNotEmpty;
    final initial = member.displayName.isNotEmpty
        ? member.displayName[0].toUpperCase()
        : '?';

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        children: [
          // Member avatar
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withValues(alpha: 0.08),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    member.profilePictureUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildInitial(context, initial),
                  )
                : _buildInitial(context, initial),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.email != null && member.email!.isNotEmpty)
                  Text(
                    member.email!,
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isLeader)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                l10n.leader,
                style: AppTypography.caption.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitial(BuildContext context, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
      ),
    );
  }
}
