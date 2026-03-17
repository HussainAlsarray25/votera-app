import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';

/// A sliver list of compact project items. Each item shows an emoji icon,
/// title, description, category tag, team member avatars, and vote count.
class ProjectListSection extends StatelessWidget {
  const ProjectListSection({required this.projects, super.key});

  final List<DemoProject> projects;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProjectListItem(project: projects[index]),
            );
          },
          childCount: projects.length,
        ),
      ),
    );
  }
}

class _ProjectListItem extends StatelessWidget {
  const _ProjectListItem({required this.project});

  final DemoProject project;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildEmojiIcon(),
          const SizedBox(width: 14),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// Rounded square with a soft gradient background and the project emoji
  Widget _buildEmojiIcon() {
    final bgColors = CategoryStyles.iconBackground(project.category);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: bgColors),
      ),
      child: Center(
        child: Text(project.emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(),
        const SizedBox(height: 4),
        Text(
          project.description,
          style: AppTypography.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFooterRow(),
      ],
    );
  }

  /// Title on the left, category tag on the right
  Widget _buildTitleRow() {
    final styles = CategoryStyles.tagStyles(project.category);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            project.title,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: styles.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            project.category,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: styles.text,
            ),
          ),
        ),
      ],
    );
  }

  /// Overlapping member avatars and vote count
  Widget _buildFooterRow() {
    return Row(
      children: [
        _MemberAvatarStack(members: project.members),
        const SizedBox(width: 10),
        const Icon(
          Icons.favorite_rounded,
          size: 12,
          color: AppColors.primary,
        ),
        const SizedBox(width: 3),
        Text(
          '${project.votes}',
          style: AppTypography.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

/// Row of overlapping circular member avatars with gradient backgrounds.
class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.members});

  final List<DemoTeamMember> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: members.length * 18.0 + 4,
      height: 22,
      child: Stack(
        children: List.generate(members.length, (i) {
          return Positioned(
            left: i * 16.0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: members[i].colors),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  members[i].initial,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
