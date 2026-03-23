import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';

/// Displays the project title, status, and description.
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
        // Loading/error states are handled by the parent page
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(ProjectEntity project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndStatus(project),
        const SizedBox(height: AppSpacing.lg),
        _buildDescription(project),
      ],
    );
  }

  Widget _buildTitleAndStatus(ProjectEntity project) {
    final statusLabel = project.status == ProjectStatus.submitted
        ? 'Submitted'
        : 'Draft';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            statusLabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(project.title, style: AppTypography.h2),
      ],
    );
  }

  Widget _buildDescription(ProjectEntity project) {
    if (project.description == null || project.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this Project', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          project.description!,
          style: AppTypography.bodyMedium.copyWith(height: 1.7),
        ),
      ],
    );
  }
}
