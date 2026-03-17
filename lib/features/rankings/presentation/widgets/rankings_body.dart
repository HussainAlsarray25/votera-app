import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_list_item.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_podium_section.dart';

/// Reusable body content for the Rankings display.
/// Shows podium for top 3 and a scrollable list for the rest.
/// Used inside ExhibitionDetailPage as a tab body.
class RankingsBody extends StatelessWidget {
  const RankingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final sorted = createDemoProjects()
      ..sort((a, b) => b.votes.compareTo(a.votes));
    final topThree = sorted.take(3).toList();
    final remaining = sorted.skip(3).toList();

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
                return RankingsListItem(
                  project: remaining[index],
                  rank: index + 4,
                );
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
}