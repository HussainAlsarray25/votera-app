import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_track.dart';
import 'package:votera/features/rankings/presentation/cubit/rankings_cubit.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_list_item.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_podium_section.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

/// Reusable body content for the Rankings display.
/// Shows two tabs — Community and Supervisor — each filtered via the
/// leaderboard `track` query parameter.
/// Used inside ExhibitionDetailPage as a tab body.
class RankingsBody extends StatelessWidget {
  const RankingsBody({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _RankingsTabBar(l10n: l10n),
          Expanded(
            child: TabBarView(
              children: [
                // Each tab gets its own BlocProvider so states are independent.
                BlocProvider(
                  create: (_) => GetIt.instance<RankingsCubit>(),
                  child: _RankingsTab(
                    eventId: eventId,
                    track: LeaderboardTrack.community,
                  ),
                ),
                BlocProvider(
                  create: (_) => GetIt.instance<RankingsCubit>(),
                  child: _RankingsTab(
                    eventId: eventId,
                    track: LeaderboardTrack.supervisor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab bar with Community and Supervisor labels, styled to the design system.
class _RankingsTabBar extends StatelessWidget {
  const _RankingsTabBar({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: context.colors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.labelMedium,
        tabs: [
          Tab(text: l10n.rankingsCommunityTab),
          Tab(text: l10n.rankingsSupervisorTab),
        ],
      ),
    );
  }
}

/// Content for a single rankings tab. Loads the leaderboard for the
/// given [track] on first build and handles all display states.
class _RankingsTab extends StatefulWidget {
  const _RankingsTab({required this.eventId, required this.track});

  final String eventId;
  final LeaderboardTrack track;

  @override
  State<_RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<_RankingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  // Keep each tab's scroll position and loaded state alive when switching tabs.
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget; state updates arrive via BlocBuilder.
    unawaited(
      context.read<RankingsCubit>().loadLeaderboard(
            widget.eventId,
            track: widget.track,
          ),
    );
  }

  Future<void> _refresh() async {
    await context.read<RankingsCubit>().loadLeaderboard(
          widget.eventId,
          track: widget.track,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<RankingsCubit, RankingsState>(
      builder: (context, state) {
        if (state is RankingsLoading || state is RankingsInitial) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is RankingsError) {
          return _buildErrorState(state.message);
        }

        if (state is RankingsLoaded) {
          final entries = state.leaderboard.entries;
          if (entries.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(height: 80.h),
                  EmptyState(
                    icon: Icons.leaderboard_outlined,
                    title: l10n.noRankingsYet,
                    subtitle: l10n.rankingsWillAppear,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildRankings(entries),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRankings(List<LeaderboardEntryEntity> entries) {
    final topThree = entries.take(3).toList();
    final remaining = entries.skip(3).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: RankingsPodiumSection(topThree: topThree),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(child: _buildRankingsLabel()),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => RankingsListItem(entry: remaining[index]),
              childCount: remaining.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
      ],
    );
  }

  Widget _buildRankingsLabel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          AppLocalizations.of(context)!.rankingsLabel,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: context.colors.textHint,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSizes.iconXxl,
            color: context.colors.error,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _refresh,
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
