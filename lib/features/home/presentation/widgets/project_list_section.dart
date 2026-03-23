import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';

/// A sliver list of compact project items. Each item shows a letter icon,
/// title, and description.
class ProjectListSection extends StatelessWidget {
  const ProjectListSection({
    required this.projects,
    required this.eventId,
    super.key,
  });

  final List<ProjectEntity> projects;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProjectListItem(
                project: projects[index],
                eventId: eventId,
              ),
            );
          },
          childCount: projects.length,
        ),
      ),
    );
  }
}

/// Rotating icon background colors for project list items.
const _iconGradients = [
  [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
  [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
  [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
  [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
  [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
  [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
];

class _ProjectListItem extends StatelessWidget {
  const _ProjectListItem({
    required this.project,
    required this.eventId,
  });

  final ProjectEntity project;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/project/$eventId/${project.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
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
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(child: _buildContent(context)),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  /// Rounded square with a soft gradient background and the first letter
  Widget _buildIcon() {
    final initial =
        project.title.isNotEmpty ? project.title[0].toUpperCase() : '?';
    final bgColors =
        _iconGradients[project.title.hashCode.abs() % _iconGradients.length];

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: bgColors),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (project.description != null && project.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            project.description!,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
