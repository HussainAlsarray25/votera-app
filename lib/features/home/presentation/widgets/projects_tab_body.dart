import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/home/presentation/widgets/home_banner_section.dart';
import 'package:votera/features/home/presentation/widgets/project_list_section.dart';
import 'package:votera/features/home/presentation/widgets/search_bar_section.dart';
import 'package:votera/features/home/presentation/widgets/trending_section.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

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

  Future<void> _refresh() async {
    await context
        .read<ProjectsCubit>()
        .loadProjects(eventId: widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading || state is ProjectsInitial) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is ProjectsError) {
          return _buildErrorState(context, state.message);
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        slivers: [
        SliverToBoxAdapter(
          child: SearchBarSection(
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
          ),
        ),
        const SliverToBoxAdapter(child: HomeBannerSection()),
        if (allProjects.isNotEmpty) ...[
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
        ] else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Builder(
                builder: (context) => EmptyState(
                  icon: Icons.folder_outlined,
                  title: AppLocalizations.of(context)!.noProjectsYet,
                  subtitle: AppLocalizations.of(context)!.noProjectsDesc,
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxl),
        ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: context.colors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context
                .read<ProjectsCubit>()
                .loadProjects(eventId: widget.eventId),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
