import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/home/presentation/widgets/project_list_section.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

// Number of projects per page on this screen.
const _kPageSize = 20;

/// Displays a paginated, filtered list of projects belonging to a single
/// category. Reached by tapping a category card on the exhibition categories tab.
class CategoryProjectsPage extends StatefulWidget {
  const CategoryProjectsPage({
    required this.eventId,
    required this.categoryId,
    required this.categoryName,
    super.key,
  });

  final String eventId;
  final String categoryId;
  final String categoryName;

  @override
  State<CategoryProjectsPage> createState() => _CategoryProjectsPageState();
}

class _CategoryProjectsPageState extends State<CategoryProjectsPage> {
  int _currentPage = 1;
  int _totalPages = 1;

  void _goToPage(int page) {
    if (page == _currentPage) return;
    setState(() => _currentPage = page);
    context.read<ProjectsCubit>().loadProjects(
          eventId: widget.eventId,
          categoryId: widget.categoryId,
          page: page,
          size: _kPageSize,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CenteredContent(
        maxWidth: 900,
        child: BlocConsumer<ProjectsCubit, ProjectsState>(
          listener: (context, state) {
            // Keep pagination state in sync when a page loads successfully.
            if (state is ProjectsLoaded) {
              setState(() {
                _currentPage = state.currentPage;
                _totalPages = state.totalPages(_kPageSize);
              });
            }
          },
          builder: (context, state) => _buildScrollView(context, state),
        ),
      ),
    );
  }

  /// Wraps all states in a single scrollable view so the SliverAppBar
  /// (and its back button) is always present regardless of load state.
  Widget _buildScrollView(BuildContext context, ProjectsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final int columns = availableWidth > AppBreakpoints.tabletMax ? 3 : 2;

        return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: context.colors.surface,
          elevation: 0,
          floating: true,
          snap: true,
          title: Text(
            widget.categoryName,
            style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          ),
          iconTheme: IconThemeData(color: context.colors.textPrimary),
        ),
        if (state is ProjectsLoading || state is ProjectsInitial)
          const SliverFillRemaining(
            child: Center(child: AppLoadingIndicator()),
          )
        else if (state is ProjectsError)
          SliverFillRemaining(child: _buildError(context, state.message))
        else if (state is ProjectsLoaded && state.projects.isEmpty)
          SliverFillRemaining(child: _buildEmpty(context))
        else if (state is ProjectsLoaded) ...[
          ProjectListSection(
            projects: state.projects,
            eventId: widget.eventId,
            columns: columns,
          ),
          if (_totalPages > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.md,
                ),
                child: _buildPagination(context),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],
      ],
        );
      },
    );
  }

  // -- Numbered page controls: prev | 1 2 3 ... | next --
  Widget _buildPagination(BuildContext context) {
    final isLoading = false; // loading is handled at the top level
    final pages = _pageWindow(_currentPage, _totalPages);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prev arrow
        _PageArrow(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 1 && !isLoading,
          onTap: () => _goToPage(_currentPage - 1),
        ),
        SizedBox(width: AppSpacing.xs),

        // Page number buttons with optional leading / trailing ellipsis
        if (pages.first > 1) ...[
          _PageChip(page: 1, isCurrent: false, onTap: () => _goToPage(1)),
          if (pages.first > 2) const _Ellipsis(),
        ],
        ...pages.map(
          (p) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: _PageChip(
              page: p,
              isCurrent: p == _currentPage,
              onTap: isLoading ? null : () => _goToPage(p),
            ),
          ),
        ),
        if (pages.last < _totalPages) ...[
          if (pages.last < _totalPages - 1) const _Ellipsis(),
          _PageChip(
            page: _totalPages,
            isCurrent: false,
            onTap: () => _goToPage(_totalPages),
          ),
        ],

        SizedBox(width: AppSpacing.xs),
        // Next arrow
        _PageArrow(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < _totalPages && !isLoading,
          onTap: () => _goToPage(_currentPage + 1),
        ),
      ],
    );
  }

  /// Returns at most 5 page numbers centered around [current].
  List<int> _pageWindow(int current, int total) {
    const window = 5;
    int start = (current - window ~/ 2).clamp(1, total);
    int end = (start + window - 1).clamp(1, total);
    if (end - start + 1 < window) {
      start = (end - window + 1).clamp(1, total);
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: EmptyState(
        icon: Icons.folder_open_outlined,
        title: l10n.noProjectsInCategory,
        subtitle: l10n.noProjectsInCategoryDesc,
        showRefreshHint: false,
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
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
            onPressed: () => context.read<ProjectsCubit>().loadProjects(
                  eventId: widget.eventId,
                  categoryId: widget.categoryId,
                ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Pagination sub-widgets — same visual style as comments pagination
// =============================================================================

class _PageChip extends StatelessWidget {
  const _PageChip({
    required this.page,
    required this.isCurrent,
    required this.onTap,
  });

  final int page;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36.r,
        height: 36.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCurrent ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color:
                isCurrent ? context.colors.primary : context.colors.border,
          ),
        ),
        child: Text(
          '$page',
          style: AppTypography.labelMedium.copyWith(
            color: isCurrent
                ? context.colors.textOnPrimary
                : context.colors.textPrimary,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36.r,
        height: 36.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: context.colors.border),
        ),
        child: Icon(
          icon,
          size: AppSizes.iconSm,
          color: enabled ? context.colors.textPrimary : context.colors.textHint,
        ),
      ),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Text(
        '…',
        style: AppTypography.bodyMedium.copyWith(
          color: context.colors.textHint,
        ),
      ),
    );
  }
}
