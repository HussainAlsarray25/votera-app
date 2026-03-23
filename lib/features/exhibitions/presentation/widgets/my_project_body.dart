import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/create_edit_team_sheet.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

// -- Record type for the edit project bottom sheet result --
typedef _ProjectFormResult = ({
  String title,
  String? description,
  String? repoUrl,
  String? demoUrl,
  String? techStack,
});

/// Tab body for the "My Project" tab in an exhibition.
/// Only shown to authenticated non-visitor users.
///
/// Handles three distinct cases:
///   1. User has no team       → prompt to create a team
///   2. User has a team but no project → inline form to submit a project
///   3. User has a project     → project card with edit / review actions
///
/// Owns both a [TeamsCubit] and a [ProjectsCubit] so this tab's state is
/// fully isolated from the rest of the exhibition page.
class MyProjectBody extends StatelessWidget {
  const MyProjectBody({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Team is loaded first; the project is loaded after the team state resolves.
        BlocProvider<TeamsCubit>(
          create: (_) => sl<TeamsCubit>()..loadMyTeam(),
        ),
        // ProjectsCubit starts idle — the TeamLoaded listener triggers loadMyProject.
        BlocProvider<ProjectsCubit>(
          create: (_) => sl<ProjectsCubit>(),
        ),
      ],
      child: _MyProjectView(eventId: eventId),
    );
  }
}

// =============================================================================
// Main view: orchestrates state from both cubits
// =============================================================================

class _MyProjectView extends StatefulWidget {
  const _MyProjectView({required this.eventId});

  final String eventId;

  @override
  State<_MyProjectView> createState() => _MyProjectViewState();
}

class _MyProjectViewState extends State<_MyProjectView> {
  Future<void> _refresh() async {
    // Reloading the team will trigger the TeamLoaded listener, which in turn
    // reloads the project. This covers all refresh scenarios.
    context.read<TeamsCubit>().loadMyTeam();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // When team resolves (initial load or after creation), load the project.
        BlocListener<TeamsCubit, TeamsState>(
          listenWhen: (previous, current) =>
              current is TeamLoaded && previous is! TeamLoaded,
          listener: (ctx, _) {
            ctx
                .read<ProjectsCubit>()
                .loadMyProject(eventId: widget.eventId);
          },
        ),
        // Team action errors (e.g. create team rejected) → snackbar.
        BlocListener<TeamsCubit, TeamsState>(
          listenWhen: (_, current) => current is TeamsActionFailed,
          listener: (ctx, state) {
            _showSnackBar(ctx, (state as TeamsActionFailed).message);
          },
        ),
        // Project action errors (create, edit, finalize, cancel) → snackbar.
        // The view is preserved so the user can see the error and retry.
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) => current is ProjectActionFailed,
          listener: (ctx, state) {
            _showSnackBar(ctx, (state as ProjectActionFailed).message);
          },
        ),
        // After any successful project mutation, reload to settle back
        // into the MyProjectLoaded state with the latest server data.
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) => current is ProjectSaved,
          listener: (ctx, _) {
            ctx
                .read<ProjectsCubit>()
                .loadMyProject(eventId: widget.eventId);
          },
        ),
      ],
      child: BlocBuilder<TeamsCubit, TeamsState>(
        builder: (context, teamState) {
          // While the team is being fetched, show a full-tab spinner.
          if (teamState is TeamsInitial || teamState is TeamsLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          // No team found — show the create-team prompt.
          if (teamState is TeamsError) {
            return _NoTeamPrompt(onRefresh: _refresh);
          }

          // Team is confirmed. Now check the project state.
          return BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, projectState) {
              if (projectState is ProjectsInitial ||
                  projectState is ProjectsLoading ||
                  // ProjectSaved is a transient state before the re-load lands.
                  projectState is ProjectSaved) {
                return const Center(child: AppLoadingIndicator());
              }

              if (projectState is ProjectsError) {
                return _buildLoadError(
                  context,
                  message: projectState.message,
                  onRetry: () => context
                      .read<ProjectsCubit>()
                      .loadMyProject(eventId: widget.eventId),
                );
              }

              if (projectState is MyProjectNotFound) {
                return _CreateProjectForm(
                  eventId: widget.eventId,
                  onRefresh: _refresh,
                );
              }

              if (projectState is MyProjectLoaded) {
                return _ProjectView(
                  project: projectState.project,
                  eventId: widget.eventId,
                  onRefresh: _refresh,
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Case 1: No team
// =============================================================================

/// Shown when the user is not part of any team.
/// Offers a button to create a team via the shared bottom sheet.
class _NoTeamPrompt extends StatelessWidget {
  const _NoTeamPrompt({required this.onRefresh});

  final Future<void> Function() onRefresh;

  Future<void> _openCreateTeamSheet(BuildContext context) async {
    final result = await showCreateEditTeamSheet(context);
    if (result == null) return;
    if (!context.mounted) return;
    context.read<TeamsCubit>().create(
          name: result.name,
          description: result.description,
        );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 440,
          child: Center(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleIcon(
                    icon: Icons.group_add_outlined,
                    color: context.colors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppLocalizations.of(context)!.needATeamFirst,
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppLocalizations.of(context)!.needATeamDesc,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<TeamsCubit, TeamsState>(
                    builder: (ctx, state) => GradientButton(
                      text: AppLocalizations.of(context)!.createATeam,
                      isLoading: state is TeamsLoading,
                      onPressed: () => _openCreateTeamSheet(ctx),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Case 2: Has team, no project — inline submission form
// =============================================================================

class _CreateProjectForm extends StatefulWidget {
  const _CreateProjectForm({
    required this.eventId,
    required this.onRefresh,
  });

  final String eventId;
  final Future<void> Function() onRefresh;

  @override
  State<_CreateProjectForm> createState() => _CreateProjectFormState();
}

class _CreateProjectFormState extends State<_CreateProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _techStackController;
  late final TextEditingController _repoUrlController;
  late final TextEditingController _demoUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _techStackController = TextEditingController();
    _repoUrlController = TextEditingController();
    _demoUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _repoUrlController.dispose();
    _demoUrlController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProjectsCubit>().createProject(
          eventId: widget.eventId,
          title: _titleController.text.trim(),
          description: _nullIfEmpty(_descriptionController.text),
          techStack: _nullIfEmpty(_techStackController.text),
          repoUrl: _nullIfEmpty(_repoUrlController.text),
          demoUrl: _nullIfEmpty(_demoUrlController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.pagePadding
            .copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.submitYourProject,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.submitYourProjectDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.projectTitle,
                    controller: _titleController,
                    hint: l10n.projectTitleHint,
                    prefixIcon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.projectTitleRequired;
                      }
                      if (value.trim().length < 3) {
                        return l10n.projectTitleTooShort;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.descriptionLabel,
                    controller: _descriptionController,
                    hint: l10n.descriptionHint,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.techStackLabel,
                    controller: _techStackController,
                    hint: l10n.techStackHint,
                    prefixIcon: Icons.layers_outlined,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.repositoryUrl,
                    controller: _repoUrlController,
                    hint: l10n.repositoryUrlHint,
                    prefixIcon: Icons.code_outlined,
                    keyboardType: TextInputType.url,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.demoUrl,
                    controller: _demoUrlController,
                    hint: l10n.demoUrlHint,
                    prefixIcon: Icons.open_in_new_outlined,
                    keyboardType: TextInputType.url,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (ctx, state) => GradientButton(
                  text: AppLocalizations.of(ctx)!.submitProject,
                  isLoading: state is ProjectsLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Case 3: Has project
// =============================================================================

class _ProjectView extends StatelessWidget {
  const _ProjectView({
    required this.project,
    required this.eventId,
    required this.onRefresh,
  });

  final ProjectEntity project;
  final String eventId;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.pagePadding
            .copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBanner(status: project.status),
            const SizedBox(height: AppSpacing.lg),
            _ProjectDetailsCard(
              project: project,
              onViewDetails: () =>
                  context.push('/project/$eventId/${project.id}'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProjectActionsRow(project: project, eventId: eventId),
          ],
        ),
      ),
    );
  }
}

// -- Action buttons: edit, submit for review, cancel submission --

class _ProjectActionsRow extends StatelessWidget {
  const _ProjectActionsRow({
    required this.project,
    required this.eventId,
  });

  final ProjectEntity project;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (ctx, state) {
        final isLoading = state is ProjectsLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Edit is available while the project is still modifiable.
            if (project.status == ProjectStatus.draft ||
                project.status == ProjectStatus.submitted)
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _openEditSheet(ctx),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(AppLocalizations.of(ctx)!.editProjectButton),
              ),

            if (project.status == ProjectStatus.draft) ...[
              const SizedBox(height: AppSpacing.sm),
              GradientButton(
                text: AppLocalizations.of(ctx)!.submitForReview,
                isLoading: isLoading,
                onPressed: () => _confirmFinalize(ctx),
              ),
            ],

            if (project.status == ProjectStatus.submitted) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _confirmCancel(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ctx.colors.error,
                  side: BorderSide(color: ctx.colors.error),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(AppLocalizations.of(ctx)!.cancelSubmission),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _openEditSheet(BuildContext context) async {
    final result = await showEditProjectSheet(context, project);
    if (result == null) return;
    if (!context.mounted) return;
    context.read<ProjectsCubit>().editProject(
          eventId: eventId,
          projectId: project.id,
          title: result.title,
          description: result.description,
          techStack: result.techStack,
          repoUrl: result.repoUrl,
          demoUrl: result.demoUrl,
        );
  }

  Future<void> _confirmFinalize(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.submitForReviewTitle),
        content: Text(l10n.submitForReviewDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.notYet),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.submit,
              style: TextStyle(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<ProjectsCubit>().finalize(
          eventId: eventId,
          projectId: project.id,
        );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.cancelSubmissionTitle),
        content: Text(l10n.cancelSubmissionDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.keepSubmitted),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.cancelSubmissionButton,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<ProjectsCubit>().cancel(
          eventId: eventId,
          projectId: project.id,
        );
  }
}

// -- Status banner: communicates the project's current review stage --

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (color, icon, label) = switch (status) {
      ProjectStatus.draft => (
          context.colors.warning,
          Icons.edit_note_outlined,
          l10n.draftStatusBanner,
        ),
      ProjectStatus.submitted => (
          context.colors.info,
          Icons.hourglass_top_outlined,
          l10n.submittedStatusBanner,
        ),
      ProjectStatus.accepted => (
          context.colors.success,
          Icons.check_circle_outline,
          l10n.acceptedStatusBanner,
        ),
      ProjectStatus.rejected => (
          context.colors.error,
          Icons.cancel_outlined,
          l10n.rejectedStatusBanner,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Project details card: title, description, tech stack, links, date --

class _ProjectDetailsCard extends StatelessWidget {
  const _ProjectDetailsCard({
    required this.project,
    required this.onViewDetails,
  });

  final ProjectEntity project;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with View button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onViewDetails,
                child: Text(AppLocalizations.of(context)!.viewProject),
              ),
            ],
          ),

          if (project.description != null &&
              project.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              project.description!,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (project.techStack != null &&
              project.techStack!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 14,
                  color: context.colors.textHint,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    project.techStack!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.border),
          const SizedBox(height: AppSpacing.sm),

          _buildLinks(context),

          if (project.createdAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildMeta(
              context: context,
              icon: Icons.calendar_today_outlined,
              label: AppLocalizations.of(context)!.createdLabel,
              value: _formatDate(project.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinks(BuildContext context) {
    final hasRepo = project.repoUrl != null && project.repoUrl!.isNotEmpty;
    final hasDemo = project.demoUrl != null && project.demoUrl!.isNotEmpty;

    if (!hasRepo && !hasDemo) {
      return Text(
        AppLocalizations.of(context)!.noLinksAdded,
        style: AppTypography.bodySmall.copyWith(color: context.colors.textHint),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (hasRepo)
          _LinkChip(
            icon: Icons.code_outlined,
            label: AppLocalizations.of(context)!.repositoryChip,
          ),
        if (hasDemo)
          _LinkChip(
            icon: Icons.open_in_new_outlined,
            label: AppLocalizations.of(context)!.demoChip,
          ),
      ],
    );
  }

  Widget _buildMeta({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.colors.textHint),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: ',
          style: AppTypography.caption.copyWith(color: context.colors.textHint),
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

// =============================================================================
// Edit project bottom sheet
// =============================================================================

/// Opens a modal sheet pre-filled with the project's current values.
/// Returns updated field values or null if the user cancels.
Future<_ProjectFormResult?> showEditProjectSheet(
  BuildContext context,
  ProjectEntity project,
) {
  return showModalBottomSheet<_ProjectFormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProjectSheet(project: project),
  );
}

class _EditProjectSheet extends StatefulWidget {
  const _EditProjectSheet({required this.project});

  final ProjectEntity project;

  @override
  State<_EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends State<_EditProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _techStackController;
  late final TextEditingController _repoUrlController;
  late final TextEditingController _demoUrlController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.project.title);
    _descriptionController =
        TextEditingController(text: widget.project.description ?? '');
    _techStackController =
        TextEditingController(text: widget.project.techStack ?? '');
    _repoUrlController =
        TextEditingController(text: widget.project.repoUrl ?? '');
    _demoUrlController =
        TextEditingController(text: widget.project.demoUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _repoUrlController.dispose();
    _demoUrlController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      title: _titleController.text.trim(),
      description: _nullIfEmpty(_descriptionController.text),
      repoUrl: _nullIfEmpty(_repoUrlController.text),
      demoUrl: _nullIfEmpty(_demoUrlController.text),
      techStack: _nullIfEmpty(_techStackController.text),
    ) as _ProjectFormResult);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.editProject,
                style: AppTypography.h3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.editProjectDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.projectTitle,
                    controller: _titleController,
                    prefixIcon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.projectTitleRequired;
                      }
                      if (value.trim().length < 3) {
                        return l10n.projectTitleTooShort;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.descriptionLabel,
                    controller: _descriptionController,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.techStackLabel,
                    controller: _techStackController,
                    hint: l10n.techStackHint,
                    prefixIcon: Icons.layers_outlined,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.repositoryUrl,
                    controller: _repoUrlController,
                    prefixIcon: Icons.code_outlined,
                    keyboardType: TextInputType.url,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return AppTextField(
                    label: l10n.demoUrl,
                    controller: _demoUrlController,
                    prefixIcon: Icons.open_in_new_outlined,
                    keyboardType: TextInputType.url,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              GradientButton(
                text: AppLocalizations.of(context)!.saveChanges,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: AppTypography.labelMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared small widgets
// =============================================================================

/// Circular icon container used in empty-state illustrations.
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 36, color: color),
    );
  }
}

/// Display-only chip showing a link type label.
class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
