import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/widgets/home_banner_section.dart';
import 'package:votera/features/home/presentation/widgets/project_list_section.dart';
import 'package:votera/features/home/presentation/widgets/search_bar_section.dart';
import 'package:votera/features/home/presentation/widgets/trending_section.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';

/// Reusable body for the Projects tab.
/// Contains search, banner, trending, and project list.
/// Loads real project data via ProjectsCubit.
class ProjectsTabBody extends StatefulWidget {
  const ProjectsTabBody({required this.eventId, super.key});

  final String eventId;

  @override
  State<ProjectsTabBody> createState() => _ProjectsTabBodyState();
}

class _ProjectsTabBodyState extends State<ProjectsTabBody> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProjectsCubit>().loadProjects(eventId: widget.eventId);
  }

  /// Filters the project list by search query (client-side).
  List<ProjectEntity> _filterProjects(List<ProjectEntity> projects) {
    if (_searchQuery.isEmpty) return projects;
    final query = _searchQuery.toLowerCase();
    return projects.where((project) {
      return project.title.toLowerCase().contains(query) ||
          (project.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading || state is ProjectsInitial) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is ProjectsError) {
          return _buildErrorState(state.message);
        }

        if (state is ProjectsLoaded) {
          final filtered = _filterProjects(state.projects);
          return _buildContent(state.projects, filtered);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(
    List<ProjectEntity> allProjects,
    List<ProjectEntity> filteredProjects,
  ) {
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
        if (allProjects.isNotEmpty)
          SliverToBoxAdapter(
            child: TrendingSection(
              projects: allProjects.take(4).toList(),
              eventId: widget.eventId,
            ),
          ),
        ProjectListSection(
          projects: filteredProjects,
          eventId: widget.eventId,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
      ],
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
            onPressed: () => context
                .read<ProjectsCubit>()
                .loadProjects(eventId: widget.eventId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
