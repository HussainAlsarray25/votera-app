import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';
import 'package:votera/features/rankings/presentation/cubit/rankings_cubit.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_list_item.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_podium_section.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';
import 'package:votera/shared/widgets/failure_state.dart';

/// Reusable body content for the Rankings display.
/// Loads the weighted overall voting results (no track filter).
/// Used inside ExhibitionDetailPage as a tab body.
class RankingsBody extends StatefulWidget {
  const RankingsBody({required this.eventId, super.key});

  final String eventId;

  @override
  State<RankingsBody> createState() => _RankingsBodyState();
}

class _RankingsBodyState extends State<RankingsBody> {
  late final RankingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<RankingsCubit>();
    unawaited(_cubit.loadVotingResults(widget.eventId));
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _cubit.loadVotingResults(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<RankingsCubit, RankingsState>(
        builder: (context, state) {
          if (state is RankingsLoading || state is RankingsInitial) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is RankingsError) {
            return Center(
              child: FailureState(
                message: state.message,
                onRetry: _refresh,
              ),
            );
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
              child: _buildRankings(context, entries),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRankings(
    BuildContext context,
    List<LeaderboardEntryEntity> entries,
  ) {
    final topThree = entries.take(3).toList();
    final remaining = entries.skip(3).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: RankingsPodiumSection(topThree: topThree),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(child: _buildRankingsLabel(context)),
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
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  Widget _buildRankingsLabel(BuildContext context) {
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
}
