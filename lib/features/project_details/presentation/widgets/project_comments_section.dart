import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';

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
          body: text,
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
    return Row(
      children: [
        Text('Comments', style: AppTypography.labelLarge),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '${_comments.length}',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
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
            icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
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
                'No comments yet. Be the first!',
                style: AppTypography.bodySmall,
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
            backgroundColor: AppColors.secondaryLight,
            child: Text(
              initial,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.secondary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorId,
                      style: AppTypography.labelMedium,
                    ),
                    const Spacer(),
                    if (timeAgo.isNotEmpty)
                      Text(timeAgo, style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.body, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
