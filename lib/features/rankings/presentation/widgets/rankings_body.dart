import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';
import 'package:votera/features/rankings/presentation/cubit/rankings_cubit.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_list_item.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_podium_section.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

/// Reusable body content for the Rankings display.
/// Shows podium for top 3 and a scrollable list for the rest.
/// Used inside ExhibitionDetailPage as a tab body.
class RankingsBody extends StatefulWidget {
  const RankingsBody({required this.eventId, super.key});

  final String eventId;

  @override
  State<RankingsBody> createState() => _RankingsBodyState();
}

class _RankingsBodyState extends State<RankingsBody> {
  @override
  void initState() {
    super.initState();
    context.read<RankingsCubit>().loadLeaderboard(widget.eventId);
  }

  Future<void> _refresh() async {
    await context
        .read<RankingsCubit>()
        .loadLeaderboard(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
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
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.leaderboard_outlined,
                    title: 'No rankings yet',
                    subtitle:
                        'Rankings will appear once voting begins.',
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
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: RankingsPodiumSection(topThree: topThree),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(child: _buildRankingsLabel()),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RankingsListItem(entry: remaining[index]);
              },
              childCount: remaining.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
      ],
    );
  }

  Widget _buildRankingsLabel() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'RANKINGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textHint,
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
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () =>
                context.read<RankingsCubit>().loadLeaderboard(widget.eventId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
