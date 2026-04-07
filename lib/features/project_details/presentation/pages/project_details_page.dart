import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_snack_bar.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:votera/features/project_details/presentation/widgets/project_comments_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_header_section.dart';
import 'package:votera/features/project_details/presentation/widgets/project_images_section.dart';
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
    this.coverUrl,
    super.key,
  });

  final String eventId;
  final String projectId;

  /// Cover image URL passed from the project card for immediate Hero display.
  /// Used as a placeholder while the full project details load from the API.
  final String? coverUrl;

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
            ..loadEventLocation(eventId: eventId),
        ),
      ],
      child: _ProjectDetailsView(
        eventId: eventId,
        projectId: projectId,
        coverUrl: coverUrl,
      ),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  const _ProjectDetailsView({
    required this.eventId,
    required this.projectId,
    this.coverUrl,
  });

  final String eventId;
  final String projectId;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final isWide = !AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: context.colors.background,
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
                      Icon(
                        Icons.error_outline,
                        size: AppSizes.iconXxl,
                        color: context.colors.error,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(state.message, style: AppTypography.bodyMedium.copyWith(color: context.colors.textPrimary)),
                      SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => context
                            .read<ProjectsCubit>()
                            .loadProjectById(
                              eventId: eventId,
                              projectId: projectId,
                            ),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProjectDetailLoaded) {
                return CustomScrollView(
                  slivers: [
                    ProjectHeaderSection(
                      eventId: eventId,
                      projectId: projectId,
                      coverUrl: coverUrl,
                    ),
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
      showAppSnackBar(context, state.message);
    } else if (state is LocationUnavailable) {
      showAppSnackBar(
        context,
        state.message,
        action: state.isDeniedForever
            ? SnackBarAction(
                label: AppLocalizations.of(context)!.settings,
                onPressed: Geolocator.openAppSettings,
              )
            : null,
      );
    }
  }

  Widget _buildBody(BuildContext context, {required bool showInlineVote}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectInfoSection(projectId: projectId),
          SizedBox(height: AppSpacing.lg),
          const ProjectImagesSection(),
          SizedBox(height: AppSpacing.lg),
          ProjectRatingSection(projectId: projectId),
          if (showInlineVote) ...[
            SizedBox(height: AppSpacing.lg),
            _buildVoteButton(context),
          ],
          SizedBox(height: AppSpacing.xl),
          _buildSectionDivider(context, AppLocalizations.of(context)!.communityFeedback),
          SizedBox(height: AppSpacing.md),
          ProjectCommentsSection(projectId: projectId),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(BuildContext context, String label) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(child: Divider(color: context.colors.border)),
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
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
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
