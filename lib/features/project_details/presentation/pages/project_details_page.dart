import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:votera/features/project_details/presentation/widgets/project_comments_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_header_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_info_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_rating_section.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:votera/features/voting/presentation/cubit/voting_cubit.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/vote_button.dart';

/// Full details screen for a single project.
/// Shows the image, author info, rating, description, and comments.
/// On desktop, constrains content width and places the vote button inline.
class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({
    required this.eventId,
    required this.projectId,
    super.key,
  });

  final String eventId;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectsCubit>(
          create: (_) => sl<ProjectsCubit>()
            ..loadProjectById(eventId: eventId, projectId: projectId),
        ),
        BlocProvider<RatingsCubit>(
          create: (_) => sl<RatingsCubit>()..loadSummary(projectId),
        ),
        BlocProvider<CommentsCubit>(
          create: (_) => sl<CommentsCubit>()
            ..loadComments(projectId: projectId),
        ),
        BlocProvider<VotingCubit>(
          create: (_) => sl<VotingCubit>()
            ..loadMyVotes(eventId: eventId)
            ..prefetchVotingArea(eventId: eventId),
        ),
      ],
      child: _ProjectDetailsView(
        eventId: eventId,
        projectId: projectId,
      ),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  const _ProjectDetailsView({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final isWide = !AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CenteredContent(
        maxWidth: 900,
        child: BlocListener<VotingCubit, VotingState>(
          listener: _handleVotingState,
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              if (state is ProjectsLoading || state is ProjectsInitial) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state is ProjectsError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(state.message, style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => context
                            .read<ProjectsCubit>()
                            .loadProjectById(
                              eventId: eventId,
                              projectId: projectId,
                            ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProjectDetailLoaded) {
                return CustomScrollView(
                  slivers: [
                    const ProjectHeaderSection(),
                    SliverToBoxAdapter(
                      child: _buildBody(
                        context,
                        showInlineVote: isWide,
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      bottomNavigationBar: isWide ? null : _buildBottomBar(context),
    );
  }

  void _handleVotingState(BuildContext context, VotingState state) {
    if (state is OutsideVotingArea) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is LocationUnavailable) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            action: state.isDeniedForever
                ? const SnackBarAction(
                    label: 'Settings',
                    onPressed: Geolocator.openAppSettings,
                  )
                : null,
          ),
        );
    }
  }

  Widget _buildBody(BuildContext context, {required bool showInlineVote}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectInfoSection(projectId: projectId),
          const SizedBox(height: AppSpacing.lg),
          ProjectRatingSection(projectId: projectId),
          if (showInlineVote) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildVoteButton(context),
          ],
          const SizedBox(height: AppSpacing.xl),
          _buildSectionDivider('Community Feedback'),
          const SizedBox(height: AppSpacing.md),
          ProjectCommentsSection(projectId: projectId),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildVoteButton(BuildContext context) {
    return BlocBuilder<VotingCubit, VotingState>(
      builder: (context, state) {
        // Show loading indicator during location check.
        if (state is VotingLocationCheck) {
          return const Center(child: AppLoadingIndicator());
        }

        final hasVoted = state is VotesLoaded &&
            state.votes.any((v) => v.projectId == projectId);

        return VoteButton(
          hasVoted: hasVoted,
          onVote: () => context.read<VotingCubit>().submitVote(
                eventId: eventId,
                projectId: projectId,
              ),
        );
      },
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildVoteButton(context),
      ),
    );
  }
}
