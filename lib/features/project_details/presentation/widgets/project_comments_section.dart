import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';

/// Displays a list of user comments and an input section to add a new one.
/// Each comment carries a 1–5 star score alongside text.
/// Reads from and dispatches to [CommentsCubit].
class ProjectCommentsSection extends StatefulWidget {
  const ProjectCommentsSection({required this.projectId, super.key});

  final String projectId;

  @override
  State<ProjectCommentsSection> createState() => _ProjectCommentsSectionState();
}

class _ProjectCommentsSectionState extends State<ProjectCommentsSection> {
  final _commentController = TextEditingController();
  final _comments = <CommentEntity>[];

  // The star score the user has picked before submitting (defaults to 0 = none selected)
  int _selectedScore = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _commentController.text.trim();
    if (text.isEmpty || _selectedScore == 0) return;

    context.read<CommentsCubit>().addComment(
          projectId: widget.projectId,
          text: text,
          score: _selectedScore,
        );

    _commentController.clear();
    setState(() => _selectedScore = 0);
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
          setState(() => _comments.insert(0, state.comment));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentInput(),
          const SizedBox(height: AppSpacing.lg),
          _buildCommentsList(),
        ],
      ),
    );
  }

  // -- Section: comment input with score picker --
  Widget _buildCommentInput() {
    final canSubmit =
        _selectedScore > 0 && _commentController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Star score picker
          Text(
            'How would you rate it?',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedStarRating(
            rating: _selectedScore,
            size: 48,
            onRatingChanged: (score) => setState(() => _selectedScore = score),
          ),
          const SizedBox(height: AppSpacing.md),
          // Text field
          TextField(
            controller: _commentController,
            maxLines: 3,
            minLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Write your comment...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Submit button — full width
          SizedBox(
            width: double.infinity,
            child: AnimatedOpacity(
              opacity: canSubmit ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: FilledButton.icon(
                onPressed: canSubmit ? _handleSend : null,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Post Comment'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Section: scrollable list or empty/loading state --
  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return BlocBuilder<CommentsCubit, CommentsState>(
        builder: (context, state) {
          if (state is CommentsLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 40,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No feedback yet. Be the first!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (int i = 0; i < _comments.length; i++) ...[
            _buildCommentItem(_comments[i]),
            if (i < _comments.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name
                Text(
                  comment.authorId,
                  style: AppTypography.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (comment.score != null && comment.score! > 0)
                  AnimatedStarRating(
                    rating: comment.score!,
                    size: 14,
                    isInteractive: false,
                  ),
                if (timeAgo.isNotEmpty)
                  Text(
                    timeAgo,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
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
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
