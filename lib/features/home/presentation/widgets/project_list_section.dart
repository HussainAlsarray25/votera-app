import 'package:flutter/material.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/shared/widgets/project_entity_card.dart';

/// A 2-column sliver grid of project cards.
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
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
