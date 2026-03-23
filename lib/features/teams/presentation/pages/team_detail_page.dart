import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/team_member_tile.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';

/// Detail view for a team opened from the Browse search results.
///
/// Displays the team's header, description, and a read-only member list.
/// Leadership actions are not available here — they live on the My Team tab.
class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({required this.teamId, super.key});

  final String teamId;

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late final TeamsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<TeamsCubit>();
    unawaited(_cubit.loadTeam(widget.teamId));
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocBuilder<TeamsCubit, TeamsState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is TeamsLoading || state is TeamsInitial) {
            return const _LoadingView();
          }
          if (state is TeamLoaded) {
            return _TeamDetailView(team: state.team);
          }
          if (state is TeamsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => unawaited(_cubit.loadTeam(widget.teamId)),
            );
          }
          return const _LoadingView();
        },
      ),
    );
  }
}

// =============================================================================
// Views
// =============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: const Center(child: AppLoadingIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(backgroundColor: context.colors.surface),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: context.colors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamDetailView extends StatelessWidget {
  const _TeamDetailView({required this.team});

  final TeamEntity team;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _TeamDetailAppBar(team: team),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (team.description != null && team.description!.isNotEmpty) ...[
                _DescriptionCard(description: team.description!),
                const SizedBox(height: AppSpacing.md),
              ],
              _MembersCard(team: team),
              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Inner widgets
// =============================================================================

/// Gradient SliverAppBar with team name, member count, and back button.
class _TeamDetailAppBar extends StatelessWidget {
  const _TeamDetailAppBar({required this.team});

  final TeamEntity team;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.secondary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient fill
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles
            const Positioned(
              top: -20,
              right: -16,
              child: _Circle(size: 120, opacity: 0.08),
            ),
            const Positioned(
              top: 30,
              right: 50,
              child: _Circle(size: 64, opacity: 0.1),
            ),
            const Positioned(
              bottom: -10,
              right: 100,
              child: _Circle(size: 40, opacity: 0.06),
            ),
            // Team info
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.group_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    team.name,
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 13,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.memberCount(team.members.length),
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.about,
            style: AppTypography.labelLarge.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.team});

  final TeamEntity team;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.membersWithCount(team.members.length),
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...team.members.map(
          (member) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TeamMemberTile(
              member: member,
              isLeader: member.userId == team.leaderId,
            ),
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}