import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/cached_image.dart';

/// Displays a paginated list of project comments with numbered page controls.
/// Each page holds 10 comments. Tapping a page number loads that page.
class ProjectCommentsSection extends StatefulWidget {
  const ProjectCommentsSection({required this.projectId, super.key});

  final String projectId;

  @override
  State<ProjectCommentsSection> createState() => _ProjectCommentsSectionState();
}

class _ProjectCommentsSectionState extends State<ProjectCommentsSection> {
  final _comments = <CommentEntity>[];
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  void _goToPage(int page) {
    if (page == _currentPage) return;
    context.read<CommentsCubit>().loadComments(
          projectId: widget.projectId,
          page: page,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state is CommentsLoaded) {
          setState(() {
            _comments
              ..clear()
              ..addAll(state.comments);
            _currentPage = state.page;
            _totalPages = state.totalPages;
            _total = state.total;
          });
        } else if (state is CommentPosted) {
          setState(() => _comments.insert(0, state.comment));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppSpacing.md),
          _buildCommentsList(),
          if (_totalPages > 1) ...[
            SizedBox(height: AppSpacing.md),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  // -- Section header with total count --
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          l10n.comments,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '$_total',
            style: AppTypography.caption.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // -- Comments list or empty / loading state --
  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return BlocBuilder<CommentsCubit, CommentsState>(
        builder: (context, state) {
          if (state is CommentsLoading) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noCommentsYet,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: _comments.map(_buildCommentItem).toList(),
    );
  }

  // -- Numbered page buttons: prev | 1 2 3 ... | next --
  Widget _buildPagination() {
    // Compute the window of page numbers to show (at most 5 around current).
    final pages = _pageWindow(_currentPage, _totalPages);

    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        final isLoading = state is CommentsLoading;

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
              if (pages.first > 2) _Ellipsis(),
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
              if (pages.last < _totalPages - 1) _Ellipsis(),
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
      },
    );
  }

  /// Returns a list of at most 5 page numbers centered around [current].
  List<int> _pageWindow(int current, int total) {
    const window = 5;
    int start = (current - window ~/ 2).clamp(1, total);
    int end = (start + window - 1).clamp(1, total);
    if (end - start + 1 < window) {
      start = (end - window + 1).clamp(1, total);
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  // -- Single comment row --
  Widget _buildCommentItem(CommentEntity comment) {
    final displayName = comment.authorName?.isNotEmpty == true
        ? comment.authorName!
        : comment.authorId;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final timeAgo =
        comment.createdAt != null ? _formatTimeAgo(comment.createdAt!) : '';

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedAvatar(
            radius: 18,
            url: comment.authorAvatarUrl,
            initial: initial,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTypography.labelMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timeAgo.isNotEmpty)
                      Text(
                        timeAgo,
                        style: AppTypography.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
                if (comment.score != null) ...[
                  const SizedBox(height: 2),
                  _buildStarRating(comment.score!),
                ],
                if (comment.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int score) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < score ? Icons.star_rounded : Icons.star_outline_rounded,
          size: AppSizes.iconXs,
          color: index < score ? Colors.amber : context.colors.textSecondary,
        );
      }),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return l10n.daysAgo(diff.inDays);
    if (diff.inHours > 0) return l10n.hoursAgo(diff.inHours);
    if (diff.inMinutes > 0) return l10n.minutesAgo(diff.inMinutes);
    return l10n.justNow;
  }
}

// =============================================================================
// Pagination sub-widgets
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
          color: isCurrent
              ? context.colors.primary
              : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isCurrent
                ? context.colors.primary
                : context.colors.border,
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
          color: enabled
              ? context.colors.textPrimary
              : context.colors.textHint,
        ),
      ),
    );
  }
}

class _Ellipsis extends StatelessWidget {
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
