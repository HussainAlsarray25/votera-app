import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Displays a list of user comments and an input field to add a new one.
/// Reads from and dispatches to CommentsCubit.
class ProjectCommentsSection extends StatefulWidget {
  const ProjectCommentsSection({required this.projectId, super.key});

  final String projectId;

  @override
  State<ProjectCommentsSection> createState() => _ProjectCommentsSectionState();
}

class _ProjectCommentsSectionState extends State<ProjectCommentsSection> {
  final _commentController = TextEditingController();
  final _comments = <CommentEntity>[];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    context.read<CommentsCubit>().addComment(
          projectId: widget.projectId,
          text: text,
          score: 1,
        );
    _commentController.clear();
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
          });
        } else if (state is CommentPosted) {
          // Prepend the new comment to the list
          setState(() => _comments.insert(0, state.comment));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.md),
          _buildCommentInput(),
          const SizedBox(height: AppSpacing.md),
          _buildCommentsList(),
        ],
      ),
    );
  }

  // -- Section: Comments header with count --
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
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '${_comments.length}',
            style: AppTypography.caption.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // -- Section: New comment input --
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: context.colors.primaryLight,
            child: Icon(
              Icons.person,
              size: 16,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addComment,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: context.colors.primary, size: 20),
            onPressed: _handleSend,
          ),
        ],
      ),
);
  }

  // -- Section: Comments list --
  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return BlocBuilder<CommentsCubit, CommentsState>(
        builder: (context, state) {
          if (state is CommentsLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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

  Widget _buildCommentItem(CommentEntity comment) {
    final initial = comment.authorId.isNotEmpty
        ? comment.authorId[0].toUpperCase()
        : '?';
    final timeAgo = comment.createdAt != null
        ? _formatTimeAgo(comment.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.secondaryLight,
            child: Text(
              initial,
              style: AppTypography.labelMedium.copyWith(
                color: context.colors.secondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorId,
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
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
