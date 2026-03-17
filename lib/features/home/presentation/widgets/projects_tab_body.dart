import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';
import 'package:votera/features/home/presentation/widgets/category_filter_section.dart';
import 'package:votera/features/home/presentation/widgets/home_banner_section.dart';
import 'package:votera/features/home/presentation/widgets/project_list_section.dart';
import 'package:votera/features/home/presentation/widgets/search_bar_section.dart';
import 'package:votera/features/home/presentation/widgets/trending_section.dart';

/// Reusable body for the Projects tab.
/// Contains search, banner, trending, category filter, and project list.
/// Used both in the standalone HomePage and inside ExhibitionDetailPage tabs.
class ProjectsTabBody extends StatefulWidget {
  const ProjectsTabBody({super.key});

  @override
  State<ProjectsTabBody> createState() => _ProjectsTabBodyState();
}

class _ProjectsTabBodyState extends State<ProjectsTabBody> {
  final List<DemoProject> _projects = createDemoProjects();
  String _selectedCategory = 'All Projects';
  String _searchQuery = '';

  /// Projects filtered by the active category and search query
  List<DemoProject> get _filteredProjects {
    return _projects.where((project) {
      final matchesCategory = _selectedCategory == 'All Projects' ||
          project.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          project.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.teamName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Top projects by vote count for the trending section
  List<DemoProject> get _trendingProjects {
    final sorted = List<DemoProject>.from(_projects)
      ..sort((a, b) => b.votes.compareTo(a.votes));
    return sorted.take(4).toList();
  }

  void _handleVote(DemoProject project) {
    setState(() {
      project
        ..isVoted = !project.isVoted
        ..votes += project.isVoted ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SearchBarSection(
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
          ),
        ),
        const SliverToBoxAdapter(child: HomeBannerSection()),
        SliverToBoxAdapter(
          child: TrendingSection(
            projects: _trendingProjects,
            onVote: _handleVote,
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryFilterSection(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
        ),
        ProjectListSection(projects: _filteredProjects),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
      ],
    );
  }
}
