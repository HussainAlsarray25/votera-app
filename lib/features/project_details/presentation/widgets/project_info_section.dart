import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';

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
          return _buildContent(state.project);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(ProjectEntity project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (project.description != null && project.description!.isNotEmpty)
          _buildDescription(project.description!),
        if (project.techStack != null && project.techStack!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildTechStack(project.techStack!),
        ],
        if (_hasLinks(project)) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildLinks(project),
        ],
      ],
    );
  }

  Widget _buildDescription(String description) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'About this Project', icon: Icons.info_outline_rounded),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.75,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStack(String techStack) {
    // Split by comma, semicolon, or space-separated list
    final chips = techStack
        .split(RegExp(r'[,;]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Tech Stack', icon: Icons.layers_outlined),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map(_buildTechChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLinks(ProjectEntity project) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Project Links', icon: Icons.link_rounded),
          const SizedBox(height: AppSpacing.sm),
          if (project.repoUrl != null && project.repoUrl!.isNotEmpty)
            _LinkRow(
              icon: Icons.code_rounded,
              label: 'Source Code',
              url: project.repoUrl!,
            ),
          if (project.demoUrl != null && project.demoUrl!.isNotEmpty) ...[
            if (project.repoUrl != null && project.repoUrl!.isNotEmpty)
              const SizedBox(height: AppSpacing.sm),
            _LinkRow(
              icon: Icons.open_in_new_rounded,
              label: 'Live Demo',
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
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
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
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
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () {
          // URL launching is handled by the caller in a real integration.
          // Keeping this widget free of url_launcher to stay dependency-light.
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.labelMedium),
                    Text(
                      url,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
