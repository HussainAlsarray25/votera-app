import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/project_entity_card.dart';

/// Horizontal scrollable section showing the top trending projects.
/// Uses the same [ProjectEntityCard] as the vertical project list.
class TrendingSection extends StatelessWidget {
  const TrendingSection({
    required this.projects,
    required this.eventId,
    super.key,
  });

  final List<ProjectEntity> projects;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: AppSpacing.sm),
        // Use LayoutBuilder so the card width and height exactly match the
        // 2-column grid (same padding, spacing, and aspect ratio).
        LayoutBuilder(
          builder: (context, constraints) {
            const gridPadding = 16.0;
            const gridSpacing = 12.0;
            const aspectRatio = 0.78;
            final cardWidth =
                (constraints.maxWidth - gridPadding * 2 - gridSpacing) / 2;
            final cardHeight = cardWidth / aspectRatio;

            return SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: gridPadding),
                itemCount: projects.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: gridSpacing),
                itemBuilder: (context, index) {
                  return ProjectEntityCard(
                    project: projects[index],
                    eventId: eventId,
                    width: cardWidth,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.trendingNow,
            style: AppTypography.h3.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            l10n.seeAll,
            style: AppTypography.labelMedium.copyWith(
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
