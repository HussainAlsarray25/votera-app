import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Shows the project description, tech stack chips, and links (repo/demo).
/// Reads from the ProjectsCubit state provided by the parent page.
class ProjectInfoSection extends StatelessWidget {
  const ProjectInfoSection({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectDetailLoaded) {
          return _buildContent(context, state.project);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, ProjectEntity project) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (project.description != null && project.description!.isNotEmpty)
          _buildDescription(context, l10n, project.description!),
        if (project.techStack != null && project.techStack!.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          _buildTechStack(context, l10n, project.techStack!),
        ],
        if (_hasLinks(project)) ...[
          SizedBox(height: AppSpacing.lg),
          _buildLinks(context, l10n, project),
        ],
      ],
    );
  }

  Widget _buildDescription(BuildContext context, AppLocalizations l10n, String description) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: l10n.aboutProject,
            icon: Icons.info_outline_rounded,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.75,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStack(BuildContext context, AppLocalizations l10n, String techStack) {
    final chips = techStack
        .split(RegExp(r'[,;]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: l10n.techStack,
            icon: Icons.layers_outlined,
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: chips
                .map((label) => _buildTechChip(context, label))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLinks(BuildContext context, AppLocalizations l10n, ProjectEntity project) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: l10n.projectLinks,
            icon: Icons.link_rounded,
          ),
          SizedBox(height: AppSpacing.sm),
          if (project.repoUrl != null && project.repoUrl!.isNotEmpty)
            _LinkRow(
              icon: Icons.code_rounded,
              label: l10n.sourceCode,
              url: project.repoUrl!,
            ),
          if (project.demoUrl != null && project.demoUrl!.isNotEmpty) ...[
            if (project.repoUrl != null && project.repoUrl!.isNotEmpty)
              SizedBox(height: AppSpacing.sm),
            _LinkRow(
              icon: Icons.open_in_new_rounded,
              label: l10n.liveDemo,
              url: project.demoUrl!,
            ),
          ],
        ],
      ),
    );
  }

  bool _hasLinks(ProjectEntity project) {
    return (project.repoUrl != null && project.repoUrl!.isNotEmpty) ||
        (project.demoUrl != null && project.demoUrl!.isNotEmpty);
  }
}

// -- Shared card container for each info section --
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: child,
    );
  }
}

// -- Labeled row with an icon for section headers --
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: context.colors.primary),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppTypography.labelLarge
              .copyWith(color: context.colors.textPrimary),
        ),
      ],
    );
  }
}

// -- Tappable link row for repo / demo URLs --
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: context.colors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.labelMedium),
                    Text(
                      url,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: AppSizes.iconSm,
                color: context.colors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
