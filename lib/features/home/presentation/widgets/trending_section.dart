import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Rotating gradient palette for trending card headers.
const _trendingGradients = [
  [Color(0xFF0F172A), Color(0xFF1E3A5F)],
  [Color(0xFFDBEAFE), Color(0xFFC7D2FE)],
  [Color(0xFFFEF9C3), Color(0xFFFED7AA)],
  [Color(0xFFFCE7F3), Color(0xFFF5D0FE)],
  [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
];

/// Horizontal scrollable section showing the top trending projects.
/// Each card has a colored header with project info.
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
        SizedBox(
          height: 220,
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
                  index: index,
                  eventId: eventId,
                ),
              );
            },
          ),
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
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: context.colors.error,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.trendingNow,
                style: AppTypography.h3.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.project,
    required this.index,
    required this.eventId,
  });

  final ProjectEntity project;
  final int index;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/project/$eventId/${project.id}'),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: context.colors.surface,
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
            _buildCardInfo(context),
          ],
        ),
      ),
    );
  }

  /// Gradient header with letter icon
  Widget _buildCardImage() {
    final gradientColors =
        _trendingGradients[index % _trendingGradients.length];
    final initial =
        project.title.isNotEmpty ? project.title[0].toUpperCase() : '?';
    // Use dark text if the background is light
    final isLightBg =
        gradientColors.first.computeLuminance() > 0.5;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        gradient: LinearGradient(colors: gradientColors),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: isLightBg ? const Color(0xFF4B5563) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: AppTypography.labelMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (project.description != null &&
              project.description!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              project.description!,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
