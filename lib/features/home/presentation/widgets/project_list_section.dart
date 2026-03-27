import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/shared/widgets/project_entity_card.dart';

/// A responsive sliver grid of project cards.
/// Columns adapt to the screen width: 1 on mobile, 2 on tablet, 3 on desktop.
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
    final columns = AppBreakpoints.projectGridColumns(context);

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.sm + 4,
          mainAxisSpacing: AppSpacing.sm + 4,
          // Tall enough for thumbnail + status badge + 2-line title +
          // description + meta row without overflow.
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProjectEntityCard(
              project: projects[index],
              eventId: eventId,
            );
          },
          childCount: projects.length,
        ),
      ),
    );
  }
}
