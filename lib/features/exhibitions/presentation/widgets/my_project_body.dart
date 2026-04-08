import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/shared/widgets/app_snack_bar.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';
import 'package:votera/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/features/projects/domain/entities/extra_image_entity.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/shared/widgets/cached_image.dart';
import 'package:votera/shared/widgets/empty_state.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/create_edit_team_sheet.dart';
import 'package:votera/shared/widgets/app_dialog.dart';
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
/// Handles four distinct cases:
///   0. Event is not open (voting/closed/draft/archived) → locked empty state
///   1. User has no team       → prompt to create a team
///   2. User has a team but no project → inline form to submit a project
///   3. User has a project     → project card with edit / review actions
///
/// Owns both a [TeamsCubit] and a [ProjectsCubit] so this tab's state is
/// fully isolated from the rest of the exhibition page.
class MyProjectBody extends StatelessWidget {
  const MyProjectBody({
    required this.eventId,
    required this.eventStatus,
    super.key,
  });

  final String eventId;

  /// The lifecycle status of the event. When not [EventStatus.open],
  /// submissions are blocked and a themed empty state is shown instead.
  final EventStatus eventStatus;

  @override
  Widget build(BuildContext context) {
    // Allow project management during both open and voting phases.
    // All other phases (draft, closed, archived) show a locked state.
    final canManageProject =
        eventStatus == EventStatus.open || eventStatus == EventStatus.voting;
    if (!canManageProject) {
      return _EventNotOpenState(status: eventStatus);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<TeamsCubit>(
          create: (_) => sl<TeamsCubit>()..loadMyTeam(),
        ),
        // Load the project immediately — the API does not require a team_id.
        // This lets us auto-identify the correct team from project.teamId,
        // avoiding the team picker for users who already have a project.
        BlocProvider<ProjectsCubit>(
          create: (_) => sl<ProjectsCubit>()..loadMyProject(eventId: eventId),
        ),
      ],
      child: _MyProjectView(eventId: eventId),
    );
  }
}

// =============================================================================
// Case 0: Event is not open — submissions locked
// =============================================================================

/// Shown when the event status does not allow project submissions.
/// Each lifecycle phase has its own icon and message so the user understands
/// exactly why they cannot submit, without a generic error.
class _EventNotOpenState extends StatelessWidget {
  const _EventNotOpenState({required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (icon, title, subtitle) = switch (status) {
      EventStatus.voting => (
          Icons.how_to_vote_outlined,
          l10n.votingPhaseTitle,
          l10n.votingPhaseDesc,
        ),
      EventStatus.closed => (
          Icons.event_busy_outlined,
          l10n.eventClosedTitle,
          l10n.eventClosedDesc,
        ),
      EventStatus.archived => (
          Icons.inventory_2_outlined,
          l10n.eventArchivedTitle,
          l10n.eventArchivedDesc,
        ),
      // draft — event exists but submissions window hasn't opened yet.
      _ => (
          Icons.schedule_outlined,
          l10n.eventNotStartedTitle,
          l10n.eventNotStartedDesc,
        ),
    };

    return Center(
      child: EmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
        showRefreshHint: false,
      ),
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
  // The team identified for this event. Set automatically from project.teamId
  // when the project loads, or via the team picker for first-time submissions.
  TeamEntity? _selectedTeam;

  // All teams the current user belongs to, stored here so listeners and the
  // build method can access them without re-reading from the cubit state.
  List<TeamEntity> _loadedTeams = [];

  // Key used to call into the create form state and upload a pending cover
  // after the project has been saved and its ID is available.
  final _createFormKey = GlobalKey<_CreateProjectFormState>();

  void _selectTeam(TeamEntity team) {
    setState(() => _selectedTeam = team);
    context.read<ProjectsCubit>().loadMyProject(
          eventId: widget.eventId,
          teamId: team.id,
        );
  }

  void _loadMyProject() {
    context.read<ProjectsCubit>().loadMyProject(
          eventId: widget.eventId,
          teamId: _selectedTeam?.id,
        );
  }

  /// Reloads the project without emitting a loading state.
  /// Used after image/category operations so the project view stays visible
  /// while the data refreshes in the background.
  void _silentReloadMyProject() {
    context.read<ProjectsCubit>().reloadMyProjectSilent(
          eventId: widget.eventId,
          teamId: _selectedTeam?.id,
        );
  }

  Future<void> _refresh() async {
    context.read<TeamsCubit>().loadMyTeam();
    // Also reload the project independently — the API does not require a
    // team_id, so this works even before a team has been selected.
    _loadMyProject();
  }

  void _showSnackBar(BuildContext context, String message) {
    showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // When the team list resolves, store it and try to identify the
        // correct team. We no longer trigger project loading here because
        // the project is already loading in parallel via ProjectsCubit.
        BlocListener<TeamsCubit, TeamsState>(
          listenWhen: (_, current) =>
              current is MyTeamsLoaded || current is TeamLoaded,
          listener: (ctx, state) {
            List<TeamEntity> teams = [];
            if (state is MyTeamsLoaded) teams = state.teams;
            if (state is TeamLoaded) teams = [state.team];

            if (teams.isEmpty) return;

            // Use List.from to ensure the runtime type is List<TeamEntity>,
            // not List<TeamModel>, which would break firstWhere's type inference.
            setState(() => _loadedTeams = List<TeamEntity>.from(teams));

            if (_selectedTeam != null) return; // Already identified, nothing to do.

            // If the project has already loaded, use its teamId to match the
            // correct team without requiring any user interaction.
            final projectState = ctx.read<ProjectsCubit>().state;
            if (projectState is MyProjectLoaded) {
              final match = teams.firstWhere(
                (t) => t.id == projectState.project.teamId,
                orElse: () => teams.first,
              );
              setState(() => _selectedTeam = match);
              return;
            }

            // Project not loaded yet. For a single team, auto-select now so
            // the create form is ready when the 404 response arrives.
            if (teams.length == 1) {
              setState(() => _selectedTeam = teams.first);
            }
            // Multiple teams and no project yet — wait for project response.
            // If the project exists its teamId will identify the team.
            // If it does not exist (404) the team picker will be shown.
          },
        ),
        // When the project loads and _selectedTeam is not yet set, use
        // project.teamId to find and auto-select the matching team. This
        // handles the case where the project response arrives before the
        // team list — the team listener will also check this on arrival.
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) =>
              current is MyProjectLoaded,
          listener: (ctx, state) {
            if (state is! MyProjectLoaded) return;
            if (_selectedTeam != null) return; // Already set.
            if (_loadedTeams.isEmpty) return; // Teams not loaded yet; team listener will handle it.

            final match = _loadedTeams.firstWhere(
              (t) => t.id == state.project.teamId,
              orElse: () => _loadedTeams.first,
            );
            setState(() => _selectedTeam = match);
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
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) => current is ProjectActionFailed,
          listener: (ctx, state) {
            _showSnackBar(ctx, (state as ProjectActionFailed).message);
          },
        ),
        // After any successful project mutation, reload the project.
        // If the form had a pending cover image, upload it now that we have
        // the project ID from the saved project.
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) => current is ProjectSaved,
          listener: (ctx, state) {
            if (state is ProjectSaved) {
              _createFormKey.currentState
                  ?.uploadPendingCoverIfAny(state.project.id);
            }
            _loadMyProject();
          },
        ),
        // After deletion the project no longer exists — reload to show the
        // create-project form (backend will return 404 → MyProjectNotFound).
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) => current is ProjectDeleted,
          listener: (ctx, _) => _loadMyProject(),
        ),
        // After any image upload/deletion or category change, silently reload
        // the project so the UI reflects the latest server state without
        // showing a full-page loading spinner.
        BlocListener<ProjectsCubit, ProjectsState>(
          listenWhen: (_, current) =>
              current is ProjectCoverUploaded ||
              current is ProjectCoverDeleted ||
              current is ProjectExtraImageUploaded ||
              current is ProjectExtraImageDeleted ||
              current is ProjectCategoryUpdated,
          listener: (ctx, _) => _silentReloadMyProject(),
        ),
      ],
      child: BlocBuilder<TeamsCubit, TeamsState>(
        builder: (context, teamState) {
          // While the team list is being fetched, show a full-tab spinner.
          if (teamState is TeamsInitial || teamState is TeamsLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          // No team found — show the create-team prompt.
          final hasNoTeam = teamState is TeamsError ||
              (teamState is MyTeamsLoaded && teamState.teams.isEmpty);
          if (hasNoTeam) {
            return _NoTeamPrompt(onRefresh: _refresh);
          }

          // Teams are loaded. Now check the project state to decide what to show.
          // The project is already loading in parallel, so we do not need to
          // gate on team selection before initiating any API calls.
          return BlocBuilder<ProjectsCubit, ProjectsState>(
            // States handled silently by BlocListeners — exclude them from
            // the builder so the current view stays visible:
            //   ProjectActionFailed    → snackbar
            //   ProjectDeleted         → triggers _loadMyProject (full reload)
            //   ProjectCoverUploaded   → triggers _silentReloadMyProject
            //   ProjectCoverDeleted    → triggers _silentReloadMyProject
            //   ProjectExtraImageUploaded → triggers _silentReloadMyProject
            //   ProjectExtraImageDeleted  → triggers _silentReloadMyProject
            //   ProjectCategoryUpdated    → triggers _silentReloadMyProject
            buildWhen: (_, current) =>
                current is! ProjectActionFailed &&
                current is! ProjectDeleted &&
                current is! ProjectCoverUploaded &&
                current is! ProjectCoverDeleted &&
                current is! ProjectExtraImageUploaded &&
                current is! ProjectExtraImageDeleted &&
                current is! ProjectCategoryUpdated,
            builder: (context, projectState) {
              if (projectState is ProjectsInitial ||
                  projectState is ProjectsLoading ||
                  projectState is ProjectSaved) {
                return const Center(child: AppLoadingIndicator());
              }

              if (projectState is ProjectsError) {
                return _buildLoadError(
                  context,
                  message: projectState.message,
                  onRetry: _loadMyProject,
                );
              }

              if (projectState is MyProjectNotFound) {
                // No project yet. If the user is in multiple teams and has not
                // chosen one, show the team picker before the submission form.
                // This only applies to first-time submissions — returning users
                // have their team identified from the project response above.
                if (_loadedTeams.length > 1 && _selectedTeam == null) {
                  return _TeamSelectionGate(
                    teams: _loadedTeams,
                    onTeamSelected: _selectTeam,
                  );
                }

                return _CreateProjectForm(
                  key: _createFormKey,
                  eventId: widget.eventId,
                  teams: _loadedTeams,
                  initialTeam: _selectedTeam,
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
            Icon(Icons.error_outline, size: AppSizes.iconXxl, color: context.colors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
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
          height: 440.r,
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
                  SizedBox(height: AppSpacing.md),
                  Text(
                    AppLocalizations.of(context)!.needATeamFirst,
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    AppLocalizations.of(context)!.needATeamDesc,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  BlocBuilder<TeamsCubit, TeamsState>(
                    // Only rebuild when the loading state flips — the button
                    // only cares about whether a request is in flight.
                    buildWhen: (prev, curr) =>
                        (prev is TeamsLoading) != (curr is TeamsLoading),
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
    super.key,
    required this.eventId,
    required this.teams,
    required this.onRefresh,
    this.initialTeam,
  });

  final String eventId;

  /// All teams the current user belongs to. When this list contains more than
  /// one entry a team-picker is shown so the user can choose which team submits.
  final List<TeamEntity> teams;

  /// The team already chosen at the parent level (via [_TeamSelectionGate]).
  /// Pre-fills the picker so the user doesn't have to pick again.
  final TeamEntity? initialTeam;

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

  // The team that will own this project submission.
  late TeamEntity _selectedTeam;

  // Cover image picked locally before project creation.
  // Uploaded immediately after the project is saved and the ID is available.
  PlatformFile? _pendingCover;

  // Categories selected by the user (max 3).
  final List<CategoryEntity> _selectedCategories = [];

  // Owned directly by this state so it can be accessed without context.
  // Avoids the issue where build(context) returns the BlocProvider as a child,
  // making context.read<CategoriesCubit>() look in the wrong direction (up the
  // tree instead of down).
  late final CategoriesCubit _categoriesCubit;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _techStackController = TextEditingController();
    _repoUrlController = TextEditingController();
    _demoUrlController = TextEditingController();
    _selectedTeam = widget.initialTeam ?? widget.teams.first;
    _categoriesCubit = sl<CategoriesCubit>()..loadCategories(page: 1, size: 100);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _repoUrlController.dispose();
    _demoUrlController.dispose();
    _categoriesCubit.close();
    super.dispose();
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    // Reject large files before storing them in state — old devices crash
    // when a multi-megabyte Uint8List is held in memory during form fill.
    const maxBytes = 5 * 1024 * 1024; // 5 MB
    if (file.size > maxBytes) {
      if (mounted) {
        showAppSnackBar(context, AppLocalizations.of(context)!.imageTooLarge);
      }
      return;
    }

    setState(() => _pendingCover = file);
  }

  void _removePendingCover() => setState(() => _pendingCover = null);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProjectsCubit>().createProject(
          eventId: widget.eventId,
          teamId: _selectedTeam.id,
          title: _titleController.text.trim(),
          description: _nullIfEmpty(_descriptionController.text),
          techStack: _nullIfEmpty(_techStackController.text),
          repoUrl: _nullIfEmpty(_repoUrlController.text),
          demoUrl: _nullIfEmpty(_demoUrlController.text),
          categoryIds: _selectedCategories.isEmpty
              ? null
              : _selectedCategories.map((c) => c.id).toList(),
        );
  }

  // Opens the category picker sheet and appends the newly chosen categories
  // to the local _selectedCategories list. Uses _categoriesCubit directly
  // (field) to avoid looking up the tree with context.read.
  Future<void> _openCategoryPicker(BuildContext context) async {
    final remaining = 3 - _selectedCategories.length;
    if (remaining <= 0) return;

    final alreadySelectedIds = _selectedCategories.map((c) => c.id).toSet();

    final newIds = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _categoriesCubit,
        child: _CategoryPickerSheet(
          alreadySelectedIds: alreadySelectedIds,
          maxSelectable: remaining,
        ),
      ),
    );

    if (newIds == null || newIds.isEmpty || !mounted) return;

    // Map returned IDs back to CategoryEntity objects using the loaded list.
    final allCategories = _categoriesCubit.state is CategoriesLoaded
        ? (_categoriesCubit.state as CategoriesLoaded).response.items
        : <CategoryEntity>[];
    final toAdd = allCategories.where((c) => newIds.contains(c.id)).toList();
    setState(() => _selectedCategories.addAll(toAdd));
  }

  // Called from the BlocListener in _MyProjectViewState when ProjectSaved fires.
  // Uploads the pending cover using the newly created project ID.
  void uploadPendingCoverIfAny(String projectId) {
    final cover = _pendingCover;
    if (cover == null || cover.bytes == null) return;
    context.read<ProjectsCubit>().uploadCover(
          eventId: widget.eventId,
          projectId: projectId,
          bytes: cover.bytes!,
          contentType: _contentTypeFromFileName(cover.name),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _categoriesCubit,
      child: RefreshIndicator(
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
                  l10n.submitYourProject,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.submitYourProjectDesc,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Team picker — only shown when the user belongs to 2+ teams.
                if (widget.teams.length > 1) ...[
                  _TeamPicker(
                    teams: widget.teams,
                    selected: _selectedTeam,
                    onChanged: (team) => setState(() => _selectedTeam = team),
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],

                // Card 1: Cover image — header on top, image full-bleed below.
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: AppSpacing.cardPadding
                            .copyWith(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: AppSizes.iconSm,
                              color: context.colors.primary,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.projectImagesCard,
                              style: AppTypography.labelLarge.copyWith(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _LocalCoverSlot(
                        file: _pendingCover,
                        onPick: _pickCover,
                        onRemove: _removePendingCover,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Card 2: Basic info
                _FormSectionCard(
                  icon: Icons.edit_note_outlined,
                  title: l10n.basicInfoCard,
                  child: Column(
                    children: [
                      AppTextField(
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
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.descriptionLabel,
                        controller: _descriptionController,
                        hint: l10n.descriptionHint,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Card 3: Tech & links
                _FormSectionCard(
                  icon: Icons.layers_outlined,
                  title: l10n.techLinksCard,
                  child: Column(
                    children: [
                      AppTextField(
                        label: l10n.techStackLabel,
                        controller: _techStackController,
                        hint: l10n.techStackHint,
                        prefixIcon: Icons.layers_outlined,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.repositoryUrl,
                        controller: _repoUrlController,
                        hint: l10n.repositoryUrlHint,
                        prefixIcon: Icons.code_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.demoUrl,
                        controller: _demoUrlController,
                        hint: l10n.demoUrlHint,
                        prefixIcon: Icons.open_in_new_outlined,
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Card 4: Categories
                _FormSectionCard(
                  icon: Icons.category_outlined,
                  title: l10n.categoriesCard,
                  subtitle: l10n.categoriesCardDesc,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show selected categories as removable chips.
                      if (_selectedCategories.isNotEmpty) ...[
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _selectedCategories.map((cat) {
                            return _RemovableCategoryChip(
                              key: ValueKey(cat.id),
                              category: cat,
                              onRemove: () => setState(() =>
                                  _selectedCategories.removeWhere(
                                      (c) => c.id == cat.id)),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: AppSpacing.sm),
                      ],

                      // Empty state when nothing is selected yet.
                      if (_selectedCategories.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                            horizontal: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            border:
                                Border.all(color: context.colors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.label_outline_rounded,
                                size: AppSizes.iconSm,
                                color: context.colors.textHint,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.noCategoriesSelected,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.colors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                      ],

                      // Add button — hidden when the 3-category limit is reached.
                      if (_selectedCategories.length < 3)
                        TextButton.icon(
                          onPressed: () => _openCategoryPicker(context),
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            size: AppSizes.iconSm,
                          ),
                          label: Text(l10n.addCategory),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.primary,
                            padding: EdgeInsets.zero,
                            textStyle: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      // Max reached hint.
                      if (_selectedCategories.length >= 3) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 13.r,
                              color: context.colors.textHint,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              l10n.maxCategoriesHint,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),

                BlocBuilder<ProjectsCubit, ProjectsState>(
                  builder: (ctx, state) => GradientButton(
                    text: l10n.submitProject,
                    isLoading: state is ProjectsLoading,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
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
            SizedBox(height: AppSpacing.lg),
            _ProjectDetailsCard(
              project: project,
              onViewDetails: () =>
                  context.push('/project/$eventId/${project.id}'),
            ),
            // Image management is only available while the project is a draft.
            if (project.status == ProjectStatus.draft) ...[
              SizedBox(height: AppSpacing.lg),
              _ImageSection(project: project, eventId: eventId),
            ],
            SizedBox(height: AppSpacing.lg),
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
                onPressed: isLoading ? null : () => _openEditPage(ctx),
                icon: Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                label: Text(AppLocalizations.of(ctx)!.editProjectButton),
              ),

            if (project.status == ProjectStatus.draft) ...[
              SizedBox(height: AppSpacing.sm),
              GradientButton(
                text: AppLocalizations.of(ctx)!.submitForReview,
                isLoading: isLoading,
                onPressed: () => _confirmFinalize(ctx),
              ),
            ],

            if (project.status == ProjectStatus.submitted) ...[
              SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _confirmCancel(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ctx.colors.error,
                  side: BorderSide(color: ctx.colors.error),
                ),
                icon: Icon(Icons.cancel_outlined, size: AppSizes.iconSm),
                label: Text(AppLocalizations.of(ctx)!.cancelSubmission),
              ),
            ],

            // Delete is only available for draft projects.
            if (project.status == ProjectStatus.draft) ...[
              SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _confirmDelete(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ctx.colors.error,
                  side: BorderSide(color: ctx.colors.error),
                ),
                icon: Icon(Icons.delete_outline, size: AppSizes.iconSm),
                label: Text(AppLocalizations.of(ctx)!.deleteProject),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _openEditPage(BuildContext context) async {
    // Pass the cubit so the edit page can issue mutations without needing
    // its own provider — we share the same cubit instance.
    final cubit = context.read<ProjectsCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditProjectPage(
            eventId: eventId,
            project: project,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmFinalize(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.submitForReviewTitle,
      message: l10n.submitForReviewDesc,
      confirmLabel: l10n.submit,
      cancelLabel: l10n.notYet,
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
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.cancelSubmissionTitle,
      message: l10n.cancelSubmissionDesc,
      confirmLabel: l10n.cancelSubmissionButton,
      cancelLabel: l10n.keepSubmitted,
      isDestructive: true,
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<ProjectsCubit>().cancel(
          eventId: eventId,
          projectId: project.id,
        );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.confirmDeleteProjectTitle,
      message: l10n.confirmDeleteProjectDesc,
      confirmLabel: l10n.deleteProject,
      isDestructive: true,
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<ProjectsCubit>().delete(
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
      padding: EdgeInsets.symmetric(
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
          Icon(icon, size: AppSizes.iconMd, color: color),
          SizedBox(width: AppSpacing.sm),
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
              SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onViewDetails,
                child: Text(AppLocalizations.of(context)!.viewProject),
              ),
            ],
          ),

          if (project.description != null &&
              project.description!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
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
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: AppSizes.iconXs,
                  color: context.colors.textHint,
                ),
                SizedBox(width: AppSpacing.xs),
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

          SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.border),
          SizedBox(height: AppSpacing.sm),

          _buildLinks(context),

          if (project.createdAt != null) ...[
            SizedBox(height: AppSpacing.sm),
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
        Icon(icon, size: AppSizes.iconXs, color: context.colors.textHint),
        SizedBox(width: AppSpacing.xs),
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
        borderRadius: BorderRadius.vertical(
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
                  width: 40.r,
                  height: 4.r,
                  margin: EdgeInsets.only(bottom: AppSpacing.lg),
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
              SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.editProjectDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
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
              SizedBox(height: AppSpacing.md),
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
              SizedBox(height: AppSpacing.md),
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
              SizedBox(height: AppSpacing.md),
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
              SizedBox(height: AppSpacing.md),
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
              SizedBox(height: AppSpacing.xl),
              GradientButton(
                text: AppLocalizations.of(context)!.saveChanges,
                onPressed: _save,
              ),
              SizedBox(height: AppSpacing.sm),
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
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: AppSizes.iconXl, color: color),
    );
  }
}

// =============================================================================
// Team selection gate — shown before loading project when user has 2+ teams
// =============================================================================

/// Full-tab screen shown when the user belongs to more than one team and we
/// don't yet know which team's project to load. Once the user taps a team,
/// [onTeamSelected] fires and the parent triggers [loadMyProject].
class _TeamSelectionGate extends StatelessWidget {
  const _TeamSelectionGate({
    required this.teams,
    required this.onTeamSelected,
  });

  final List<TeamEntity> teams;
  final ValueChanged<TeamEntity> onTeamSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.xl),
          Text(
            l10n.selectTeamTitle,
            style: AppTypography.h2.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10n.selectTeamDesc,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          ...teams.map(
            (team) => _TeamTile(
              team: team,
              isSelected: false,
              onTap: () => onTeamSelected(team),
            ),
          ),
        ],
      ),
    );
  }
}

/// Team selector shown in the project creation form when the user belongs to
/// more than one team. Shows only the currently selected team as a compact card;
/// a "Change" button opens a bottom sheet to switch teams.
class _TeamPicker extends StatelessWidget {
  const _TeamPicker({
    required this.teams,
    required this.selected,
    required this.onChanged,
  });

  final List<TeamEntity> teams;
  final TeamEntity selected;
  final ValueChanged<TeamEntity> onChanged;

  Future<void> _openSheet(BuildContext context) async {
    final picked = await showModalBottomSheet<TeamEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamPickerSheet(teams: teams, currentSelected: selected),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = context.colors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          // Team avatar — cached image or initial letter fallback.
          CachedAvatar(
            radius: 20.r,
            url: selected.imageUrl,
            initial: selected.name,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (selected.description != null &&
                    selected.description!.isNotEmpty)
                  Text(
                    selected.description!,
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Opens the sheet to switch teams.
          TextButton(
            onPressed: () => _openSheet(context),
            child: Text(l10n.changeTeam),
          ),
        ],
      ),
    );
  }

  Widget _teamInitial(BuildContext context, TeamEntity team) {
    final primary = context.colors.primary;
    final letter =
        team.name.isNotEmpty ? team.name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        letter,
        style: AppTypography.labelLarge.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bottom sheet listing all teams so the user can change their selection.
class _TeamPickerSheet extends StatelessWidget {
  const _TeamPickerSheet({
    required this.teams,
    required this.currentSelected,
  });

  final List<TeamEntity> teams;
  final TeamEntity currentSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.r,
              height: 4.r,
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          Text(
            l10n.selectTeamTitle,
            style: AppTypography.h3.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10n.selectTeamDesc,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ...teams.map(
            (team) => _TeamTile(
              team: team,
              isSelected: team.id == currentSelected.id,
              onTap: () => Navigator.of(context).pop(team),
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Single selectable team tile used inside [_TeamPicker].
class _TeamTile extends StatelessWidget {
  const _TeamTile({
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  final TeamEntity team;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.5)
                : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Team avatar — cached image or initial letter fallback.
            CachedAvatar(
              radius: 18.r,
              url: team.imageUrl,
              initial: team.name,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? primary
                          : context.colors.textPrimary,
                    ),
                  ),
                  if (team.handle != null) ...[
                    SizedBox(height: 2.r),
                    Text(
                      '@${team.handle}',
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: AppSizes.iconMd,
                color: primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _initialIcon(BuildContext context) {
    final initial =
        team.name.isNotEmpty ? team.name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: AppTypography.labelMedium.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// Category section — shown on existing draft projects
// =============================================================================

/// Displays the categories currently attached to the project and lets the
/// user add more (up to 3) or remove existing ones.
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.project,
    required this.eventId,
  });

  final ProjectEntity project;
  final String eventId;

  static const int _maxCategories = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAdd = project.categories.length < _maxCategories;

    return _FormSectionCard(
      icon: Icons.category_outlined,
      title: l10n.categoriesCard,
      subtitle: l10n.categoriesCardDesc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currently attached categories as removable chips.
          if (project.categories.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: project.categories
                  .map(
                    (cat) => _RemovableCategoryChip(
                      key: ValueKey(cat.id),
                      category: cat,
                      onRemove: () => context
                          .read<ProjectsCubit>()
                          .removeCategory(
                            eventId: eventId,
                            projectId: project.id,
                            categoryId: cat.id,
                          ),
                    ),
                  )
                  .toList(),
            ),

          // Empty state — shown when no categories are attached yet.
          if (project.categories.isEmpty && canAdd) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: context.colors.border,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.label_outline_rounded,
                    size: AppSizes.iconSm,
                    color: context.colors.textHint,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.noCategoriesSelected,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // "Max reached" note — shown when all 3 slots are filled.
          if (!canAdd && project.categories.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13.r,
                  color: context.colors.textHint,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.maxCategoriesHint,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textHint,
                  ),
                ),
              ],
            ),
          ],

          if (canAdd) SizedBox(height: AppSpacing.sm),

          // Add button opens the picker sheet.
          if (canAdd)
            TextButton.icon(
              onPressed: () => _openCategoryPicker(context),
              icon: Icon(Icons.add_circle_outline_rounded, size: AppSizes.iconSm),
              label: Text(l10n.addCategory),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.primary,
                padding: EdgeInsets.zero,
                textStyle: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openCategoryPicker(BuildContext context) async {
    // The bottom sheet runs on a new route and loses access to the
    // BlocProvider<CategoriesCubit> from the parent tree. Pass the
    // existing cubit instance via BlocProvider.value so the picker
    // can still read the already-loaded categories list.
    final categoriesCubit = context.read<CategoriesCubit>();
    final projectsCubit = context.read<ProjectsCubit>();
    final alreadySelected = project.categories.map((c) => c.id).toSet();
    // How many more categories the user is allowed to add.
    final remaining = 3 - project.categories.length;

    final selectedIds = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: categoriesCubit,
        child: _CategoryPickerSheet(
          alreadySelectedIds: alreadySelected,
          maxSelectable: remaining,
        ),
      ),
    );
    if (selectedIds == null || selectedIds.isEmpty || !context.mounted) return;

    // Fire one addCategory call per selected ID. The cubit no longer emits
    // ProjectsLoading for these so the UI stays stable during the batch.
    for (final id in selectedIds) {
      projectsCubit.addCategory(
        eventId: eventId,
        projectId: project.id,
        categoryId: id,
      );
    }
  }
}

/// A chip that displays an already-attached category with a remove button.
/// Uses a solid primary background to distinguish it from selectable chips.
class _RemovableCategoryChip extends StatelessWidget {
  const _RemovableCategoryChip({
    required this.category,
    required this.onRemove,
    super.key,
  });

  final CategoryEntity category;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final onPrimary = context.colors.textOnPrimary;
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.xs,
        top: AppSpacing.xs + 2,
        bottom: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_rounded,
            size: 12.r,
            color: onPrimary.withValues(alpha: 0.75),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            category.name,
            style: AppTypography.bodySmall.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          // Remove button wrapped in a translucent circle for a pill-chip look.
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 11.r, color: onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet that lets the user pick one or more categories to add.
/// Already-selected categories are excluded. The sheet stays open while the
/// user toggles selections; tapping the "Add (n)" button confirms all at once.
class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.alreadySelectedIds,
    required this.maxSelectable,
  });

  /// Category IDs already attached to the project — hidden from the list.
  final Set<String> alreadySelectedIds;

  /// How many more categories the user may add (3 minus current count).
  final int maxSelectable;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final Set<String> _selected = {};

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < widget.maxSelectable) {
        _selected.add(id);
      }
      // If at the limit and row is not selected, tap is ignored — the
      // greyed-out appearance communicates that it can't be added.
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.r,
              height: 4.r,
              margin: EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),

          // Title + confirm button on the same row
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.selectCategory,
                  style: AppTypography.h3.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _selected.isEmpty ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: TextButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selected.toList()),
                  child: Text(
                    '${l10n.addCategory} (${_selected.length})',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading || state is CategoriesInitial) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: const Center(child: AppLoadingIndicator()),
                );
              }
              if (state is CategoriesLoaded) {
                final available = state.response.items
                    .where((c) => !widget.alreadySelectedIds.contains(c.id))
                    .toList();
                if (available.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        l10n.noCategoriesAvailable,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textHint,
                        ),
                      ),
                    ),
                  );
                }
                return Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: available.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: context.colors.divider, height: 1),
                    itemBuilder: (context, index) {
                      final cat = available[index];
                      final isSelected = _selected.contains(cat.id);
                      final atLimit = _selected.length >= widget.maxSelectable;
                      final isDisabled = atLimit && !isSelected;

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(
                          cat.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDisabled
                                ? context.colors.textHint
                                : context.colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: cat.description.isNotEmpty
                            ? Text(
                                cat.description,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: context.colors.primary,
                                size: AppSizes.iconMd,
                              )
                            : Icon(
                                Icons.circle_outlined,
                                color: isDisabled
                                    ? context.colors.border
                                    : context.colors.textHint,
                                size: AppSizes.iconMd,
                              ),
                        onTap: isDisabled ? null : () => _toggle(cat.id),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared form card — used in create form and edit page
// =============================================================================

/// A card container that groups related form fields with a labeled header.
/// Mirrors the _SectionCard style from project_info_section.dart.
class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: context.colors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// Local cover slot — used in create form before project ID exists
// =============================================================================

/// Shows a picked cover image (from local file) or an empty "tap to add" slot.
/// No API call happens here — the bytes are held in state until project creation.
class _LocalCoverSlot extends StatelessWidget {
  const _LocalCoverSlot({
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = context.colors.primary;

    if (file == null) {
      // Empty state: tap anywhere to pick a cover image.
      // Material provides the background color AND the ink surface so the
      // ripple is rendered on top of the color and remains visible.
      return Material(
        color: primary.withValues(alpha: 0.05),
        child: InkWell(
          onTap: onPick,
          child: SizedBox(
            width: double.infinity,
            height: 180.r,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: AppSizes.iconLg,
                    color: primary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.tapToAddCover,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.coverImageFormHint,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Selected local image — no ClipRRect; the parent card handles clipping.
    return Stack(
      children: [
        file!.bytes != null
            ? Image.memory(
                file!.bytes!,
                width: double.infinity,
                height: 180.r,
                fit: BoxFit.cover,
              )
            : Container(
                width: double.infinity,
                height: 180.r,
                color: context.colors.border,
              ),

        // Floating icon buttons in the top-right corner.
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingIconButton(
                icon: Icons.edit_outlined,
                onTap: onPick,
              ),
              SizedBox(width: AppSpacing.xs),
              _FloatingIconButton(
                icon: Icons.delete_outline,
                onTap: onRemove,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single selectable chip for a category.
/// Shows a filled primary background when selected to give clear visual feedback.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final onPrimary = context.colors.textOnPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? primary : context.colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon swaps between tag and checkmark based on selection state.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 13.r,
                      color: onPrimary,
                      key: const ValueKey('check'),
                    )
                  : Icon(
                      Icons.label_outline_rounded,
                      size: 13.r,
                      color: context.colors.textHint,
                      key: const ValueKey('label'),
                    ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              category.name,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? onPrimary : context.colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Image management section — cover and extra images for draft projects
// =============================================================================

/// Derives an image MIME type from a file name extension.
/// Falls back to octet-stream for unrecognized extensions.
String _contentTypeFromFileName(String name) {
  final ext = name.split('.').last.toLowerCase();
  return switch (ext) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    _ => 'application/octet-stream',
  };
}

/// Displays the cover image and up to six extra images for a draft project,
/// with controls to add or remove each image.
///
/// Visible only while the project is in [ProjectStatus.draft] since the API
/// only accepts media changes before submission.
class _ImageSection extends StatefulWidget {
  const _ImageSection({
    required this.project,
    required this.eventId,
  });

  final ProjectEntity project;
  final String eventId;

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  // Maximum extra images allowed by the API.
  static const int _maxExtraImages = 6;

  // -- Cover image actions --

  Future<void> _pickAndUploadCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    // Guard against large files crashing old devices with limited heap memory.
    const maxBytes = 5 * 1024 * 1024; // 5 MB
    if (file.size > maxBytes) {
      if (mounted) {
        showAppSnackBar(context, AppLocalizations.of(context)!.imageTooLarge);
      }
      return;
    }

    if (!mounted) return;
    context.read<ProjectsCubit>().uploadCover(
          eventId: widget.eventId,
          projectId: widget.project.id,
          bytes: file.bytes!,
          contentType: _contentTypeFromFileName(file.name),
        );
  }

  Future<void> _confirmAndRemoveCover() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.confirmRemoveCoverTitle,
      message: l10n.confirmRemoveCoverDesc,
      confirmLabel: l10n.removeImage,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    context.read<ProjectsCubit>().removeCover(
          eventId: widget.eventId,
          projectId: widget.project.id,
        );
  }

  // -- Extra image actions --

  Future<void> _pickAndUploadExtraImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    // Guard against large files crashing old devices with limited heap memory.
    const maxBytes = 5 * 1024 * 1024; // 5 MB
    if (file.size > maxBytes) {
      if (mounted) {
        showAppSnackBar(context, AppLocalizations.of(context)!.imageTooLarge);
      }
      return;
    }

    if (!mounted) return;
    context.read<ProjectsCubit>().uploadExtraImage(
          eventId: widget.eventId,
          projectId: widget.project.id,
          bytes: file.bytes!,
          contentType: _contentTypeFromFileName(file.name),
        );
  }

  Future<void> _confirmAndRemoveExtraImage(ExtraImageEntity image) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.confirmRemoveImageTitle,
      message: l10n.confirmRemoveImageDesc,
      confirmLabel: l10n.removeImage,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    context.read<ProjectsCubit>().removeExtraImage(
          eventId: widget.eventId,
          projectId: widget.project.id,
          imageId: image.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final project = widget.project;
    final extraImages = project.images;
    final canAddMore = extraImages.length < _maxExtraImages;
    final radius = AppSpacing.radiusLg;

    // Build the card manually so the cover image can be full-bleed at the top.
    // clipBehavior ensures the image respects the card's rounded corners.
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        // stretch forces the cover image to fill the card's full width.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header at the top with standard padding.
          Padding(
            padding: AppSpacing.cardPadding.copyWith(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: AppSizes.iconSm,
                  color: context.colors.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.projectImages,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Cover image — full-bleed, no inner border radius.
          _CoverImageSlot(
            coverUrl: project.coverUrl,
            onUpload: _pickAndUploadCover,
            onRemove: _confirmAndRemoveCover,
            onReplace: _pickAndUploadCover,
            innerRadius: 0,
          ),

          // Extra images section with standard padding.
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      l10n.extraImages,
                      style: AppTypography.labelMedium.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '${extraImages.length}/$_maxExtraImages',
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textHint,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                _ExtraImagesRow(
                  images: extraImages,
                  canAddMore: canAddMore,
                  onAdd: _pickAndUploadExtraImage,
                  onRemove: _confirmAndRemoveExtraImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Cover image slot --

class _CoverImageSlot extends StatelessWidget {
  const _CoverImageSlot({
    required this.coverUrl,
    required this.onUpload,
    required this.onRemove,
    required this.onReplace,
    // When the parent container already clips (full-bleed mode), pass 0 so
    // the slot does not add its own inner border radius and cause a mismatch.
    this.innerRadius,
  });

  final String? coverUrl;
  final VoidCallback onUpload;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  /// Border radius applied to the slot itself. Defaults to [AppSpacing.radiusMd].
  /// Pass `0` when the parent card handles clipping (full-bleed layout).
  final double? innerRadius;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = context.colors.primary;
    final radius = innerRadius ?? AppSpacing.radiusMd;
    final borderRadius = BorderRadius.circular(radius);

    if (coverUrl == null || coverUrl!.isEmpty) {
      // Empty state — tap to upload.
      // Material provides the background and ink surface so the ripple shows.
      return Material(
        color: primary.withValues(alpha: 0.05),
        borderRadius: radius > 0 ? borderRadius : null,
        child: InkWell(
          onTap: onUpload,
          borderRadius: radius > 0 ? borderRadius : null,
          child: Container(
            width: double.infinity,
            height: 180.r,
            decoration: radius > 0
                ? BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: AppSizes.iconLg,
                    color: primary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.addCoverImage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.coverImageFormHint,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Has a cover — show the image with floating action buttons.
    // When radius == 0 the parent card handles clipping, so no ClipRRect needed.
    final imageStack = Stack(
      children: [
        CachedImage(
          url: coverUrl!,
          width: double.infinity,
          height: 180.r,
          fit: BoxFit.cover,
        ),
        // Floating icon buttons in the top-right corner.
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingIconButton(
                icon: Icons.edit_outlined,
                onTap: onReplace,
              ),
              SizedBox(width: AppSpacing.xs),
              _FloatingIconButton(
                icon: Icons.delete_outline,
                onTap: onRemove,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );

    if (radius > 0) {
      return ClipRRect(borderRadius: borderRadius, child: imageStack);
    }
    return imageStack;
  }
}

// -- Extra images horizontal row --

class _ExtraImagesRow extends StatelessWidget {
  const _ExtraImagesRow({
    required this.images,
    required this.canAddMore,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ExtraImageEntity> images;
  final bool canAddMore;
  final VoidCallback onAdd;
  final ValueChanged<ExtraImageEntity> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tileSize = 90.r;

    return SizedBox(
      height: tileSize,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Existing images.
          ...images.map(
            (image) => Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: _ExtraImageTile(
                image: image,
                size: tileSize,
                onRemove: () => onRemove(image),
              ),
            ),
          ),
          // Add button — only when the limit hasn't been reached.
          if (canAddMore)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: context.colors.border,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: AppSizes.iconMd,
                      color: context.colors.textHint,
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      l10n.addExtraImage,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textHint,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -- Single extra image tile with remove button --

class _ExtraImageTile extends StatelessWidget {
  const _ExtraImageTile({
    required this.image,
    required this.size,
    required this.onRemove,
  });

  final ExtraImageEntity image;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: CachedImage(
            url: image.url,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        // Remove button in the top-right corner.
        Positioned(
          top: 4.r,
          right: 4.r,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14.r,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -- Floating icon button used as an overlay on cover images --

/// A compact circular icon button with a semi-transparent backdrop.
/// Used for change/remove actions overlaid on the cover image.
class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? context.colors.error : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16.r, color: color),
      ),
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
      padding: EdgeInsets.symmetric(
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
          Icon(icon, size: AppSizes.iconXs, color: context.colors.primary),
          SizedBox(width: AppSpacing.xs),
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

// =============================================================================
// Edit project full page
// =============================================================================

/// Full-page editor for an existing project.
/// Reuses the same card-based layout as the create form.
class EditProjectPage extends StatefulWidget {
  const EditProjectPage({
    super.key,
    required this.project,
    required this.eventId,
  });

  final ProjectEntity project;
  final String eventId;

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _techStackController;
  late final TextEditingController _repoUrlController;
  late final TextEditingController _demoUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description ?? '');
    _techStackController = TextEditingController(text: p.techStack ?? '');
    _repoUrlController = TextEditingController(text: p.repoUrl ?? '');
    _demoUrlController = TextEditingController(text: p.demoUrl ?? '');
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

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _isSaving = true);
    context.read<ProjectsCubit>().editProject(
          eventId: widget.eventId,
          projectId: widget.project.id,
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          techStack: _techStackController.text.trim().isEmpty
              ? null
              : _techStackController.text.trim(),
          repoUrl: _repoUrlController.text.trim().isEmpty
              ? null
              : _repoUrlController.text.trim(),
          demoUrl: _demoUrlController.text.trim().isEmpty
              ? null
              : _demoUrlController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDraft = widget.project.status == ProjectStatus.draft;

    return BlocListener<ProjectsCubit, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectSaved) {
          setState(() => _isSaving = false);
          Navigator.of(context).pop(state.project);
        } else if (state is ProjectActionFailed) {
          setState(() => _isSaving = false);
          showAppSnackBar(context, state.message, type: AppSnackBarType.error);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editProjectTitle,
                style: AppTypography.labelLarge.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.editProjectSubtitle,
                style: AppTypography.caption.copyWith(
                  color: context.colors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          actions: [
            if (_isSaving)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: SizedBox(
                  width: AppSizes.iconSm,
                  height: AppSizes.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _save,
                child: Text(
                  l10n.saveProject,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CategoriesCubit>(
              create: (ctx) =>
                  sl<CategoriesCubit>()..loadCategories(page: 1, size: 100),
            ),
          ],
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Image management — only available while project is in draft
                if (isDraft) ...[
                  _ImageSection(
                    project: widget.project,
                    eventId: widget.eventId,
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // Basic info card
                _FormSectionCard(
                  icon: Icons.info_outline_rounded,
                  title: l10n.basicInfoCard,
                  child: Column(
                    children: [
                      _buildField(
                        context,
                        controller: _titleController,
                        label: l10n.projectTitle,
                        hint: l10n.projectTitleHint,
                        maxLines: 1,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _buildField(
                        context,
                        controller: _descriptionController,
                        label: l10n.descriptionLabel,
                        hint: l10n.descriptionHint,
                        maxLines: 4,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _buildField(
                        context,
                        controller: _techStackController,
                        label: l10n.techStackLabel,
                        hint: l10n.techStackHint,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Tech links card
                _FormSectionCard(
                  icon: Icons.link_rounded,
                  title: l10n.techLinksCard,
                  child: Column(
                    children: [
                      _buildField(
                        context,
                        controller: _repoUrlController,
                        label: l10n.repositoryUrl,
                        hint: l10n.repositoryUrlHint,
                        maxLines: 1,
                        keyboardType: TextInputType.url,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _buildField(
                        context,
                        controller: _demoUrlController,
                        label: l10n.demoUrl,
                        hint: l10n.demoUrlHint,
                        maxLines: 1,
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Category management — only available while project is in draft
                if (isDraft) ...[
                  _FormSectionCard(
                    icon: Icons.category_outlined,
                    title: l10n.categoriesCard,
                    child: _CategorySection(
                      project: widget.project,
                      eventId: widget.eventId,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                GradientButton(
                  onPressed: _isSaving ? null : _save,
                  text: l10n.saveProject,
                ),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.textPrimary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: context.colors.textPrimary.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: context.colors.textPrimary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}
