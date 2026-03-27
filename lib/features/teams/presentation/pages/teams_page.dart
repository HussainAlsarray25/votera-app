import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/app/view/shell_page.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/create_edit_team_sheet.dart';
import 'package:votera/features/teams/presentation/widgets/invitation_card.dart';
import 'package:votera/features/teams/presentation/widgets/team_card.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Main teams page with two tabs: My Team and Browse.
///
/// Three separate [TeamsCubit] instances are created (all factory-registered)
/// to prevent state conflicts between team management, invitation, and search.
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Each cubit handles a distinct concern so their states never collide.
  late final TeamsCubit _teamCubit;
  late final TeamsCubit _invitationCubit;
  late final TeamsCubit _searchCubit;

  // Tracks whether the FAB should be visible (My Team tab + no teams yet).
  bool _hasTeams = true; // default true to avoid a flash on first load
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _teamCubit = sl<TeamsCubit>();
    _invitationCubit = sl<TeamsCubit>();
    _searchCubit = sl<TeamsCubit>();

    unawaited(_teamCubit.loadMyTeam());
    unawaited(_invitationCubit.loadInvitations());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    unawaited(_teamCubit.close());
    unawaited(_invitationCubit.close());
    unawaited(_searchCubit.close());
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index != _tabIndex) {
      setState(() => _tabIndex = _tabController.index);
    }
  }

  void _onTeamCubitState(TeamsState state) {
    if (state is MyTeamsLoaded) {
      setState(() => _hasTeams = state.teams.isNotEmpty);
    } else if (state is TeamsActionSuccess || state is TeamLoaded) {
      // After creating a team, reload to update FAB visibility.
      unawaited(_teamCubit.loadMyTeam());
    }
  }

  String? get _currentUserId {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) return profileState.profile.id;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showFab = _tabIndex == 0 && _hasTeams;

    return BlocListener<TeamsCubit, TeamsState>(
      bloc: _teamCubit,
      listener: (_, state) => _onTeamCubitState(state),
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: _buildAppBar(context),
        floatingActionButton: showFab
            ? FloatingActionButton.extended(
                onPressed: () => _createTeam(context),
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.textOnPrimary,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.createATeam),
              )
            : null,
        body: CenteredContent(
          child: Column(
            children: [
              _buildTabBar(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _MyTeamTab(
                      teamCubit: _teamCubit,
                      invitationCubit: _invitationCubit,
                      currentUserId: _currentUserId,
                      onSwitchToBrowse: () => _tabController.animateTo(1),
                    ),
                    _BrowseTab(searchCubit: _searchCubit),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTeam(BuildContext context) async {
    final result = await showCreateEditTeamSheet(context);
    if (result == null || !mounted) return;
    unawaited(
      _teamCubit.create(name: result.name, description: result.description),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      title: Text(
        l10n.teams,
        style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
      ),
      actions: const [NotificationIconButton()],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: context.colors.surface,
      child: TabBar(
        controller: _tabController,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.bodyMedium,
        labelColor: context.colors.textPrimary,
        unselectedLabelColor: context.colors.textHint,
        indicatorColor: context.colors.primary,
        indicatorWeight: 3,
        dividerHeight: 0,
        tabs: [
          Tab(text: l10n.myTeam),
          Tab(text: l10n.browse),
        ],
      ),
    );
  }
}

// =============================================================================
// My Team Tab
// =============================================================================

/// Shows the list of the user's teams.
/// Tapping a team enters the detail view for that team.
class _MyTeamTab extends StatefulWidget {
  const _MyTeamTab({
    required this.teamCubit,
    required this.invitationCubit,
    required this.currentUserId,
    required this.onSwitchToBrowse,
  });

  final TeamsCubit teamCubit;
  final TeamsCubit invitationCubit;
  final String? currentUserId;
  final VoidCallback onSwitchToBrowse;

  @override
  State<_MyTeamTab> createState() => _MyTeamTabState();
}

class _MyTeamTabState extends State<_MyTeamTab> {
  List<TeamEntity> _teams = [];
  List<InvitationEntity> _invitations = [];
  bool _isFirstLoad = true;
  bool _isInvitationLoading = false;

  @override
  void initState() {
    super.initState();
    final teamState = widget.teamCubit.state;
    if (teamState is MyTeamsLoaded) {
      _teams = teamState.teams;
      _isFirstLoad = false;
    } else if (teamState is TeamsError) {
      _isFirstLoad = false;
    }

    final invState = widget.invitationCubit.state;
    if (invState is InvitationsLoaded) {
      _invitations = invState.invitations
          .where((i) => i.status == InvitationStatus.pending)
          .toList();
    }
  }

  void _refresh() {
    unawaited(widget.teamCubit.loadMyTeam());
    unawaited(widget.invitationCubit.loadInvitations());
  }

  // -- Team cubit listener --

  void _onTeamState(BuildContext context, TeamsState state) {
    switch (state) {
      case TeamsLoading():
        break;

      case MyTeamsLoaded():
        setState(() {
          _teams = state.teams;
          _isFirstLoad = false;
        });

      case TeamLoaded():
        // Ignore — detail is shown on a separate page.
        break;

      case TeamsError():
        setState(() {
          _teams = [];
          _isFirstLoad = false;
        });

      case TeamsActionFailed():
        // A mutation was rejected — reload the list and show the error.
        unawaited(widget.teamCubit.loadMyTeam());
        _showSnackBar(context, state.message);

      case TeamsActionSuccess():
        unawaited(widget.teamCubit.loadMyTeam());

      case InvitationSent():
        _showSnackBar(context, AppLocalizations.of(context)!.invitationSentSuccess);

      default:
        break;
    }
  }

  // -- Invitation cubit listener --

  void _onInvitationState(BuildContext context, TeamsState state) {
    switch (state) {
      case TeamsLoading():
        setState(() => _isInvitationLoading = true);

      case InvitationsLoaded():
        setState(() {
          _invitations = state.invitations
              .where((i) => i.status == InvitationStatus.pending)
              .toList();
          _isInvitationLoading = false;
        });

      case TeamsActionSuccess():
        // The user responded to an invitation. Reload both since accepting
        // means the user now has a team.
        unawaited(widget.invitationCubit.loadInvitations());
        unawaited(widget.teamCubit.loadMyTeam());

      case TeamsActionFailed():
        // The backend rejected the action (e.g. responding to an expired invite).
        // Reload invitations so the list reflects the actual server state,
        // then surface the error message.
        setState(() => _isInvitationLoading = false);
        unawaited(widget.invitationCubit.loadInvitations());
        _showSnackBar(context, state.message);

      case TeamsError():
        setState(() {
          _invitations = [];
          _isInvitationLoading = false;
        });

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TeamsCubit, TeamsState>(
          bloc: widget.teamCubit,
          listener: _onTeamState,
        ),
        BlocListener<TeamsCubit, TeamsState>(
          bloc: widget.invitationCubit,
          listener: _onInvitationState,
        ),
      ],
      child: _buildListView(context),
    );
  }

  /// List view — shows all teams or empty state.
  Widget _buildListView(BuildContext context) {
    if (_isFirstLoad) {
      return const Center(child: AppLoadingIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: context.colors.secondary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (_teams.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: _NoTeamView(
                  invitations: _invitations,
                  isInvitationLoading: _isInvitationLoading,
                  onCreateTeam: () => _createTeam(context),
                  onBrowse: widget.onSwitchToBrowse,
                  onAcceptInvitation: (id) =>
                      widget.invitationCubit.respond(invitationId: id, accept: true),
                  onDeclineInvitation: (id) =>
                      widget.invitationCubit.respond(invitationId: id, accept: false),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TeamListTile(
                      team: _teams[index],
                      onTap: () => _openTeam(_teams[index]),
                    ),
                  ),
                  childCount: _teams.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openTeam(TeamEntity team) {
    // Refresh the list when the user returns from the detail page so any
    // delete, leave, or member-removal is immediately reflected here.
    context.push('/teams/${team.id}').then((_) {
      if (mounted) _refresh();
    });
  }

  // -- Actions -----------------------------------------------------------------

  Future<void> _createTeam(BuildContext context) async {
    final result = await showCreateEditTeamSheet(context);
    if (result == null || !mounted) return;
    unawaited(
      widget.teamCubit.create(
        name: result.name,
        description: result.description,
      ),
    );
  }
}

// =============================================================================
// Team list tile — shown in the My Teams list view
// =============================================================================

class _TeamListTile extends StatelessWidget {
  const _TeamListTile({required this.team, required this.onTap});

  final TeamEntity team;
  final VoidCallback onTap;

  // The team name that receives the royal treatment — kept in sync with team_card.dart.
  static const _royalTeamName = 'Frogs Team';

  bool get _isRoyal => team.name == _royalTeamName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasDescription =
        team.description != null && team.description!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          // Royal tile gets a very subtle dark-purple background tint.
          color: _isRoyal
              ? const Color(0xFF1A0045).withValues(alpha: 0.06)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            // Golden border for the royal team.
            color: _isRoyal
                ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                : context.colors.border,
            width: _isRoyal ? 1.5 : 1,
          ),
          boxShadow: _isRoyal
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar, name, chevron.
            Row(
              children: [
                _TeamAvatar(team: team, isRoyal: _isRoyal),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    team.name,
                    style: AppTypography.labelLarge.copyWith(
                      // Gold name text for the royal team.
                      color: _isRoyal
                          ? const Color(0xFFB8860B)
                          : context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _isRoyal
                      ? const Color(0xFFFFD700)
                      : context.colors.textHint,
                ),
              ],
            ),

            // Description snippet.
            if (hasDescription) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                team.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: AppSpacing.sm),
            Divider(
              color: _isRoyal
                  ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                  : context.colors.border,
              height: 1,
            ),
            SizedBox(height: AppSpacing.sm),

            // Footer row: member count and creation date.
            Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: AppSizes.iconXs,
                  color: context.colors.textHint,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.memberCount(team.members.length),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (team.createdAt != null) ...[
                  SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: AppSizes.iconXs,
                    color: context.colors.textHint,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatDate(team.createdAt!),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format as "Jan 2025" — concise enough for a card footer.
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Extracted so the royal crown overlay stays isolated and easy to adjust.
class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.team, required this.isRoyal});

  final TeamEntity team;
  final bool isRoyal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52.r,
      height: 52.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle.
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              gradient: isRoyal
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A0045), Color(0xFF5B0092)],
                    )
                  : null,
              color: isRoyal
                  ? null
                  : context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: isRoyal
                  ? Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: isRoyal
                  ? Text(
                      // Crown emoji instead of initial for the royal team.
                      '\u{1F451}',
                      style: TextStyle(fontSize: 24.sp),
                    )
                  : Text(
                      team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                      style: AppTypography.h3.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// No-team empty state
// =============================================================================

/// Shown in the "My Team" tab when the user has no team.
/// Displays pending invitations and CTAs to create or browse teams.
class _NoTeamView extends StatelessWidget {
  const _NoTeamView({
    required this.invitations,
    required this.isInvitationLoading,
    required this.onCreateTeam,
    required this.onBrowse,
    required this.onAcceptInvitation,
    required this.onDeclineInvitation,
  });

  final List<InvitationEntity> invitations;
  final bool isInvitationLoading;
  final VoidCallback onCreateTeam;
  final VoidCallback onBrowse;
  final void Function(String id) onAcceptInvitation;
  final void Function(String id) onDeclineInvitation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.xl),
          _buildEmptyIllustration(context),
          SizedBox(height: AppSpacing.lg),
          Text(
            AppLocalizations.of(context)!.notInTeamYet,
            style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.of(context)!.createOrJoinTeam,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          GradientButton(
            text: AppLocalizations.of(context)!.createATeam,
            onPressed: onCreateTeam,
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBrowse,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.secondary,
                side: BorderSide(color: context.colors.secondary),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.browseTeams),
            ),
          ),
          // Show pending invitations even when there's no team.
          if (invitations.isNotEmpty || isInvitationLoading) ...[
            SizedBox(height: AppSpacing.xl),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppLocalizations.of(context)!.pendingInvitations,
                style: AppTypography.labelLarge.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            ...invitations.map(
              (inv) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: InvitationCard(
                  invitation: inv,
                  onAccept: () => onAcceptInvitation(inv.id),
                  onDecline: () => onDeclineInvitation(inv.id),
                ),
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildEmptyIllustration(BuildContext context) {
    return Container(
      width: 120.r,
      height: 120.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            context.colors.secondary.withValues(alpha: 0.08),
            context.colors.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                context.colors.secondary.withValues(alpha: 0.15),
                context.colors.primary.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.group_add_rounded,
            size: AppSizes.iconXl,
            color: context.colors.secondary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Browse Tab
// =============================================================================

/// The four filter modes available when browsing teams.
enum _TeamFilter { name, teamHandle, memberName, userId }

class _BrowseTab extends StatefulWidget {
  const _BrowseTab({required this.searchCubit});

  final TeamsCubit searchCubit;

  @override
  State<_BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<_BrowseTab> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  _TeamFilter _selectedFilter = _TeamFilter.name;
  bool _showFilters = false;
  bool _hasText = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch(value.trim());
    });
  }

  void _onFilterChanged(_TeamFilter filter) {
    setState(() => _selectedFilter = filter);
    // Re-run the current query under the new filter.
    _triggerSearch(_searchController.text.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    _triggerSearch('');
  }

  void _triggerSearch(String query) {
    if (query.isEmpty) {
      widget.searchCubit.reset();
      return;
    }
    switch (_selectedFilter) {
      case _TeamFilter.name:
        unawaited(widget.searchCubit.browseTeams(name: query));
      case _TeamFilter.teamHandle:
        unawaited(widget.searchCubit.browseTeams(teamHandle: query));
      case _TeamFilter.memberName:
        unawaited(widget.searchCubit.browseTeams(userName: query));
      case _TeamFilter.userId:
        unawaited(widget.searchCubit.browseTeams(userHandle: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Whether a non-default filter is active — used to badge the filter button.
    final isFilterActive = _selectedFilter != _TeamFilter.name;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Column(
      children: [
        // Search field + filter button row (matches SearchBarSection style).
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(child: _buildSearchField(context)),
              SizedBox(width: 10.w),
              _buildFilterButton(context, isFilterActive),
            ],
          ),
        ),
        // Collapsible filter chips — visible only when the filter button is toggled.
        if (_showFilters)
          _FilterChipsBar(
            selected: _selectedFilter,
            onSelected: _onFilterChanged,
          ),
        // Results area.
        Expanded(
          child: BlocBuilder<TeamsCubit, TeamsState>(
            bloc: widget.searchCubit,
            builder: (context, state) {
              if (state is TeamsInitial) {
                return _buildSearchPrompt(context);
              }
              if (state is TeamsLoading) {
                return const Center(child: AppLoadingIndicator());
              }
              if (state is TeamsSearchResults) {
                if (state.teams.isEmpty) {
                  return _buildNoResults(context);
                }
                return _buildResults(state.teams);
              }
              if (state is TeamsError) {
                return _buildError(context, state.message);
              }
              return _buildSearchPrompt(context);
            },
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _onQueryChanged,
        style: AppTypography.bodyMedium.copyWith(
          color: context.colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchTeamsByName,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: context.colors.textHint,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.colors.textHint,
            size: AppSizes.iconMd,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Icon(
                    Icons.close_rounded,
                    color: context.colors.textHint,
                    size: AppSizes.iconSm,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _showFilters = !_showFilters),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: isActive || _showFilters
              ? context.colors.primary
              : context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (isActive || _showFilters
                      ? context.colors.primary
                      : Colors.black)
                  .withValues(alpha: isActive || _showFilters ? 0.35 : 0.04),
              blurRadius: isActive || _showFilters ? 14 : 8,
              offset: Offset(0, isActive || _showFilters ? 4 : 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              color: isActive || _showFilters
                  ? Colors.white
                  : context.colors.textSecondary,
              size: AppSizes.iconMd,
            ),
            // Dot badge when a non-default filter is active.
            if (isActive)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isActive || _showFilters
                        ? Colors.white
                        : context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRect(
      child: Center(
        child: EmptyState(
          icon: Icons.group_outlined,
          title: l10n.browse,
          subtitle: l10n.searchTeamsByName,
          showRefreshHint: false,
        ),
      ),
    );
  }


  Widget _buildNoResults(BuildContext context) {
    final query = _searchController.text.trim();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_off_rounded,
              size: AppSizes.iconXxl,
              color: context.colors.textHint,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.noTeamsFound,
              style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              query.isEmpty
                  ? 'No teams available.'
                  : AppLocalizations.of(context)!.noTeamsMatchedQuery(query),
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(List<TeamEntity> teams) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: TeamCard(
            team: team,
            index: index,
            onTap: () => context.push('/teams/${team.id}'),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppSizes.iconXxl,
              color: context.colors.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



// =============================================================================
// Small reusable widgets
// =============================================================================

// =============================================================================
// Filter chips bar
// =============================================================================

class _FilterChipsBar extends StatelessWidget {
  const _FilterChipsBar({
    required this.selected,
    required this.onSelected,
  });

  final _TeamFilter selected;
  final void Function(_TeamFilter) onSelected;

  String _label(BuildContext context, _TeamFilter filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case _TeamFilter.name:
        return l10n.teamName;
      case _TeamFilter.teamHandle:
        return l10n.teamHandle;
      case _TeamFilter.memberName:
        return l10n.memberName;
      case _TeamFilter.userId:
        return l10n.userId;
    }
  }

  Widget _buildChip(
    BuildContext context,
    _TeamFilter filter, {
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onSelected(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isActive ? context.colors.primary : context.colors.border,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          _label(context, filter),
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive
                ? context.colors.surface
                : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        itemCount: _TeamFilter.values.length,
        itemBuilder: (context, index) {
          final filter = _TeamFilter.values[index];
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: _buildChip(
              context,
              filter,
              isActive: filter == selected,
            ),
          );
        },
      ),
    );
  }
}


void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
  );
}
