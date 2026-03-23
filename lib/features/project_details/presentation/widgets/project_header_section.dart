import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Collapsible app bar with a gradient hero background, project title,
/// status badge, back button, and share action.
class ProjectHeaderSection extends StatelessWidget {
  const ProjectHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final expandedHeight = AppBreakpoints.isMobile(context) ? 280.0 : 360.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(context),
      actions: [_buildShareButton()],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) {
            final project =
                state is ProjectDetailLoaded ? state.project : null;
            return _buildBackground(project);
          },
        ),
      ),
    );
  }

  Widget _buildBackground(ProjectEntity? project) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient hero background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Subtle pattern overlay
        Opacity(
          opacity: 0.07,
          child: CustomPaint(painter: _DotGridPainter()),
        ),

        // Bottom gradient so text stays readable
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Project title + status at the bottom
        if (project != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildProjectInfo(project),
          ),

        // Decorative floating icon
        const Positioned(
          right: 24,
          top: 70,
          child: Opacity(
            opacity: 0.15,
            child: Icon(
              Icons.code_rounded,
              size: 120,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo(ProjectEntity project) {
    // Context is not directly available here; use a Builder to access it.
    return Builder(
      builder: (context) => _buildProjectInfoContent(context, project),
    );
  }

  Widget _buildProjectInfoContent(BuildContext context, ProjectEntity project) {
    final statusConfig = _statusConfig(context, project.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status badge shown below the flexible space background.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusConfig.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: statusConfig.color.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusConfig.icon, size: 11, color: statusConfig.color),
              const SizedBox(width: 4),
              Text(
                statusConfig.label,
                style: AppTypography.caption.copyWith(
                  color: statusConfig.color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Project title
        Text(
          project.title,
          style: AppTypography.h2.copyWith(
            color: Colors.white,
            shadows: [
              const Shadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: () => context.pop(),
    );
  }

  Widget _buildShareButton() {
    return IconButton(
      icon: const Icon(Icons.share, color: Colors.white),
      onPressed: () {},
    );
  }

  _StatusConfig _statusConfig(BuildContext context, ProjectStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ProjectStatus.submitted:
        return _StatusConfig(
          label: l10n.statusSubmitted,
          color: AppColors.accent,
          icon: Icons.check_circle_outline_rounded,
        );
      case ProjectStatus.accepted:
        return _StatusConfig(
          label: l10n.statusAccepted,
          color: AppColors.success,
          icon: Icons.verified_rounded,
        );
      case ProjectStatus.rejected:
        return _StatusConfig(
          label: l10n.statusRejected,
          color: AppColors.error,
          icon: Icons.cancel_outlined,
        );
      case ProjectStatus.draft:
        return _StatusConfig(
          label: l10n.statusDraft,
          color: AppColors.textHint,
          icon: Icons.edit_outlined,
        );
    }
  }
}

// -- Status data holder --
class _StatusConfig {
  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

// -- Subtle dot-grid decorative painter --
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 24.0;
    const radius = 1.5;
    final paint = Paint()..color = Colors.white;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}
