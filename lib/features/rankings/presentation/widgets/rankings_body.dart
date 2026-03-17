import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_list_item.dart';
import 'package:votera/features/rankings/presentation/widgets/rankings_podium_section.dart';

/// Reusable body content for the Rankings display.
/// Shows header, time-period tabs, podium for top 3, and a list for the rest.
/// Used both in the standalone RankingsPage and inside ExhibitionDetailPage.
class RankingsBody extends StatefulWidget {
  const RankingsBody({super.key});

  @override
  State<RankingsBody> createState() => _RankingsBodyState();
}

class _RankingsBodyState extends State<RankingsBody> {
  int _selectedTab = 0;
  final List<String> _tabs = const ['All Time', 'Weekly', 'Today'];

  // Demo data sorted by votes (descending)
  late final List<DemoProject> _sorted = createDemoProjects()
    ..sort((a, b) => b.votes.compareTo(a.votes));

  List<DemoProject> get _topThree => _sorted.take(3).toList();
  List<DemoProject> get _remaining => _sorted.skip(3).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 18),
        _buildTabBar(),
        const SizedBox(height: AppSpacing.lg),
        RankingsPodiumSection(topThree: _topThree),
        const SizedBox(height: AppSpacing.lg),
        _buildRankingsLabel(),
        const SizedBox(height: 12),
        Expanded(child: _buildRemainingList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hall of Fame',
            style: AppTypography.h1.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented tab bar with animated active indicator
  Widget _buildTabBar() {
    const activeColor = Color(0xFF1A1D2E);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = _selectedTab == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
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

  Widget _buildRemainingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _remaining.length,
      itemBuilder: (context, index) {
        return RankingsListItem(
          project: _remaining[index],
          rank: index + 4, // starts after the top 3
        );
      },
    );
  }
}
