import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Displays a list of user comments and an input field to add a new one.
class ProjectCommentsSection extends StatelessWidget {
  const ProjectCommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.md),
        _buildCommentInput(),
        const SizedBox(height: AppSpacing.md),
        _buildCommentsList(),
      ],
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
            '12',
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
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // -- Section: Comments list --
  Widget _buildCommentsList() {
    // Placeholder comment data
    const comments = [
      _Comment(
        'Sara H.',
        'Amazing project! The AR feature is incredible.',
        '2h ago',
      ),
      _Comment('Omar J.', 'Great work on the indoor navigation.', '5h ago'),
      _Comment(
        'Fatima Z.',
        'This could really help new students.',
        '1d ago',
      ),
    ];

    return Column(
      children: comments.map(_buildCommentItem).toList(),
    );
  }

  Widget _buildCommentItem(_Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondaryLight,
            child: Text(
              comment.name[0],
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
                    Text(comment.name, style: AppTypography.labelMedium),
                    const Spacer(),
                    Text(comment.time, style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Comment {
  const _Comment(this.name, this.text, this.time);
  final String name;
  final String text;
  final String time;
}
