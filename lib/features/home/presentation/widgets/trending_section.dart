import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';

/// Horizontal scrollable section showing the top trending projects.
/// Each card has a category-colored header with an emoji, project info,
/// team avatar, and a toggleable vote button.
class TrendingSection extends StatelessWidget {
  const TrendingSection({
    required this.projects,
    required this.onVote,
    super.key,
  });

  final List<DemoProject> projects;
  final ValueChanged<DemoProject> onVote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < projects.length - 1 ? 14 : 0,
                ),
                child: _TrendingCard(
                  project: projects[index],
                  onVote: () => onVote(projects[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'Trending Now',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            'See all',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.project, required this.onVote});

  final DemoProject project;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardImage(),
          _buildCardInfo(),
          const Spacer(),
          _buildCardFooter(),
        ],
      ),
    );
  }

  /// Gradient header with emoji icon and category tag
  Widget _buildCardImage() {
    final gradientColors = CategoryStyles.cardGradient(project.category);
    final tagColor = CategoryStyles.tagColor(project.category);

    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        gradient: LinearGradient(colors: gradientColors),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(project.emoji, style: const TextStyle(fontSize: 48)),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                project.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            project.description,
            style: AppTypography.bodySmall.copyWith(height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Team avatar, team name, and vote button
  Widget _buildCardFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _TeamAvatar(
                initial: project.teamInitial,
                colors: project.teamColors,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                project.teamName,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          _buildVoteChip(),
        ],
      ),
    );
  }

  Widget _buildVoteChip() {
    return GestureDetector(
      onTap: onVote,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: project.isVoted
              ? AppColors.primary
              : const Color(0xFFE8F0FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 12,
              color: project.isVoted ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              '${project.votes}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: project.isVoted ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circular avatar with a gradient background and centered initial.
class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({
    required this.initial,
    required this.colors,
    required this.size,
  });

  final String initial;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
