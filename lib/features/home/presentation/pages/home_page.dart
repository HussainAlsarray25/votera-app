import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/widgets/home_header_section.dart';
import 'package:votera/features/home/presentation/widgets/project_list_section.dart';
import 'package:votera/features/home/presentation/widgets/search_bar_section.dart';
import 'package:votera/features/home/presentation/widgets/trending_section.dart';

/// The main screen displaying projects available for voting.
/// Divided into clear visual sections that can be independently
/// updated or rearranged without affecting each other.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredContent(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: HomeHeaderSection()),
              const SliverToBoxAdapter(child: SearchBarSection()),
              const SliverToBoxAdapter(child: TrendingSection()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Text('All Projects', style: AppTypography.h3),
                ),
              ),
              const ProjectListSection(),
              // Bottom padding so the last card isn't hidden by the nav bar
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
