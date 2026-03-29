import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/widgets/project_list_section.dart';
import 'package:votera/features/home/presentation/widgets/search_bar_section.dart';
import 'package:votera/features/home/presentation/widgets/trending_section.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

/// Reusable body for the Projects tab.
/// Loads projects, wires up search (sent to the API via title param).
class ProjectsTabBody extends StatefulWidget {
  const ProjectsTabBody({required this.eventId, super.key});

  final String eventId;

  @override
  State<ProjectsTabBody> createState() => _ProjectsTabBodyState();
}

class _ProjectsTabBodyState extends State<ProjectsTabBody> {
  final ScrollController _scrollController = ScrollController();

  // Current search text shown in the bar — used to debounce API calls.
  String _searchQuery = '';

  // Debounce timer so we don't fire a request on every keystroke.
  Timer? _debounce;

  // Last successfully loaded state — kept so we can show stale content
  // instead of a full-screen spinner while a search request is in flight.
  ProjectsLoaded? _lastLoaded;

  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<ProjectsCubit>().loadProjects(eventId: widget.eventId),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<ProjectsCubit>();
    final state = cubit.state;

    if (state is! ProjectsLoaded) return;
    if (!state.hasNextPage) return;
    if (cubit.isLoadingMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      unawaited(
        cubit.loadMoreProjects(
          eventId: widget.eventId,
          existingProjects: state.projects,
          nextPage: state.currentPage + 1,
          title: _searchQuery.isEmpty ? null : _searchQuery,
        ),
      );
    }
  }

  /// Called whenever the search field changes.
  /// Fires immediately when cleared; debounces 400 ms for normal typing.
  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _debounce?.cancel();

    if (query.isEmpty) {
      // Reload all projects immediately when the field is cleared.
      unawaited(
        context.read<ProjectsCubit>().loadProjects(eventId: widget.eventId),
      );
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(
        context.read<ProjectsCubit>().loadProjects(
              eventId: widget.eventId,
              title: query,
            ),
      );
    });
  }

  Future<void> _refresh() async {
    await context.read<ProjectsCubit>().loadProjects(
          eventId: widget.eventId,
          title: _searchQuery.isEmpty ? null : _searchQuery,
        );
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoaded) {
          _lastLoaded = state;
          return _buildContent(context, state);
        }

        if (state is ProjectsError) {
          return _buildErrorState(context, state.message);
        }

        // While a search or refresh is loading, keep the previous content
        // visible so the keyboard stays open and the user is not interrupted.
        if (state is ProjectsLoading && _lastLoaded != null) {
          return _buildContent(context, _lastLoaded!);
        }

        // First-ever load — no previous content to show yet.
        return const Center(child: AppLoadingIndicator());
      },
    );
  }

  Widget _buildContent(BuildContext context, ProjectsLoaded state) {
    final cubit = context.read<ProjectsCubit>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: CenteredContent(
        // LayoutBuilder measures the actual available width after CenteredContent
        // has applied its constraint. This is the real content area width,
        // accounting for any NavigationRail or other chrome.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final int columns = availableWidth > AppBreakpoints.tabletMax ? 3 : 2;

            return RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SearchBarSection(onSearchChanged: _onSearchChanged),
          ),

          if (state.projects.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: TrendingSection(
                projects: state.projects.take(4).toList(),
                eventId: widget.eventId,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.allProjects,
                        style: AppTypography.h3.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                      ),
                      child: Text(
                        '${state.projects.length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProjectListSection(
              projects: state.projects,
              eventId: widget.eventId,
              columns: columns,
            ),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: _searchQuery.isEmpty
                    ? EmptyState(
                        icon: Icons.folder_outlined,
                        title: AppLocalizations.of(context)!.noProjectsYet,
                        subtitle: AppLocalizations.of(context)!.noProjectsDesc,
                      )
                    : EmptyState(
                        icon: Icons.search_off_rounded,
                        title: AppLocalizations.of(context)!.noProjectsFound,
                        subtitle:
                            AppLocalizations.of(context)!.noProjectsFoundDesc,
                        showRefreshHint: false,
                      ),
              ),
            ),

          if (state.hasNextPage)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: cubit.isLoadingMore
                      ? const AppLoadingIndicator()
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
        ),
      );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: AppSizes.iconXxl, color: context.colors.error),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
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
