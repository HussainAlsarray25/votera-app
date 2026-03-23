import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/app/view/shell_page.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/create_edit_team_sheet.dart';
import 'package:votera/features/teams/presentation/widgets/invitation_card.dart';
import 'package:votera/features/teams/presentation/widgets/team_card.dart';
import 'package:votera/features/teams/presentation/widgets/team_member_tile.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
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

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _teamCubit = sl<TeamsCubit>();
    _invitationCubit = sl<TeamsCubit>();
    _searchCubit = sl<TeamsCubit>();

    unawaited(_teamCubit.loadMyTeam());
    unawaited(_invitationCubit.loadInvitations());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchDebounce?.cancel();
    unawaited(_teamCubit.close());
    unawaited(_invitationCubit.close());
    unawaited(_searchCubit.close());
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) return;
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_searchCubit.search(query: query.trim()));
    });
  }

  String? get _currentUserId {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) return profileState.profile.id;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(context),
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
                  _BrowseTab(
                    searchCubit: _searchCubit,
                    onSearchChanged: _onSearchChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

/// Displays the current user's team with members and pending invitations.
///
/// Caches [_team] and [_invitations] locally so the UI never goes blank during
/// background refreshes (stale-while-revalidate pattern). Two separate cubit
/// instances are listened to independently to prevent state collisions.
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
  TeamEntity? _team;
  List<InvitationEntity> _invitations = [];
  bool _isFirstTeamLoad = true;
  bool _isInvitationLoading = false;

  bool get _isLeader =>
      _team != null && widget.currentUserId == _team!.leaderId;

  @override
  void initState() {
    super.initState();
    // When the widget is recreated after a tab switch, the cubit may already
    // hold a resolved state. Restore cached values immediately so the UI
    // doesn't show a loading spinner waiting for a re-emission that won't come.
    final teamState = widget.teamCubit.state;
    if (teamState is TeamLoaded) {
      _team = teamState.team;
      _isFirstTeamLoad = false;
    } else if (teamState is TeamsError) {
      _isFirstTeamLoad = false;
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
        // Only show the full-screen loader on the very first load.
        // Subsequent loads show stale content while refreshing.
        break;

      case TeamLoaded():
        setState(() {
          _team = state.team;
          _isFirstTeamLoad = false;
        });

      case TeamsError():
        // A 404-style error means the user has no team. Clear the cache
        // and show the empty state instead of an error banner.
        setState(() {
          _team = null;
          _isFirstTeamLoad = false;
        });

      case TeamsActionFailed():
        // A mutation was rejected by the backend (e.g. leaving as leader).
        // The team still exists — reload it so the view is restored, then
        // show the server message so the user knows what went wrong.
        unawaited(widget.teamCubit.loadMyTeam());
        _showSnackBar(context, state.message);

      case TeamsActionSuccess():
        // Void actions (leave, delete, remove, transfer) succeeded.
        // Reload to pick up the new team state.
        unawaited(widget.teamCubit.loadMyTeam());

      case InvitationSent():
        setState(() => _isFirstTeamLoad = false);
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
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        color: context.colors.secondary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_isFirstTeamLoad)
              const SliverFillRemaining(
                child: Center(child: AppLoadingIndicator()),
              )
            else if (_team == null)
              SliverFillRemaining(
                child: Center(
                  child: _NoTeamView(
                    invitations: _invitations,
                    isInvitationLoading: _isInvitationLoading,
                    onCreateTeam: () => _createTeam(context),
                    onBrowse: widget.onSwitchToBrowse,
                    onAcceptInvitation: (id) => widget.invitationCubit
                        .respond(invitationId: id, accept: true),
                    onDeclineInvitation: (id) => widget.invitationCubit
                        .respond(invitationId: id, accept: false),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TeamHeaderCard(team: _team!, isLeader: _isLeader),
                    const SizedBox(height: AppSpacing.lg),
                    _MembersSection(
                      team: _team!,
                      currentUserId: widget.currentUserId,
                      isLeader: _isLeader,
                      onRemoveMember: (memberId) =>
                          _removeMember(context, memberId),
                      onInviteMember: () => _inviteMember(context),
                    ),
                    if (_invitations.isNotEmpty || _isInvitationLoading) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _InvitationsSection(
                        invitations: _invitations,
                        isLoading: _isInvitationLoading,
                        onAccept: (id) => widget.invitationCubit
                            .respond(invitationId: id, accept: true),
                        onDecline: (id) => widget.invitationCubit
                            .respond(invitationId: id, accept: false),
                      ),
                    ],
                    if (_isLeader) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _TeamSettingsSection(
                        onEdit: () => _editTeam(context),
                        onTransfer: () => _transferLeadership(context),
                        onDelete: () => _deleteTeam(context),
                        onLeave: () => _leaveTeam(context),
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.lg),
                      Divider(color: context.colors.border),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _leaveTeam(context),
                          icon: const Icon(
                            Icons.exit_to_app_rounded,
                            size: 18,
                          ),
                          label: Text(AppLocalizations.of(context)!.leaveTeam),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
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

  Future<void> _editTeam(BuildContext context) async {
    if (_team == null) return;
    final result = await showCreateEditTeamSheet(
      context,
      initialName: _team!.name,
      initialDescription: _team!.description,
    );
    if (result == null || !mounted) return;
    unawaited(
      widget.teamCubit.update(
        teamId: _team!.id,
        name: result.name,
        description: result.description,
      ),
    );
  }

  Future<void> _inviteMember(BuildContext context) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final inviteeId = await _showInputDialog(
      context,
      title: l10n.inviteMember,
      hint: l10n.enterUserIdToInvite,
      confirmLabel: l10n.sendInvite,
    );
    if (inviteeId == null || !mounted) return;
    unawaited(
      widget.teamCubit.invite(teamId: _team!.id, inviteeId: inviteeId),
    );
  }

  Future<void> _removeMember(BuildContext context, String memberId) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      context,
      title: l10n.removeMember,
      message: l10n.removeMemberConfirm,
      confirmLabel: l10n.remove,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(
      widget.teamCubit.remove(teamId: _team!.id, memberId: memberId),
    );
  }

  Future<void> _transferLeadership(BuildContext context) async {
    if (_team == null) return;

    // Eligible candidates are all members except the current leader.
    final candidates = _team!.members
        .where((m) => m.userId != _team!.leaderId)
        .toList();

    final l10n = AppLocalizations.of(context)!;
    if (candidates.isEmpty) {
      _showSnackBar(context, l10n.noMembersForLeadership);
      return;
    }

    final newLeaderId = await _showMemberPickerSheet(
      context,
      title: l10n.transferLeadership,
      subtitle: l10n.selectNewLeader,
      members: candidates,
    );
    if (newLeaderId == null || !mounted) return;
    unawaited(
      widget.teamCubit.transfer(teamId: _team!.id, newLeaderId: newLeaderId),
    );
  }

  Future<void> _leaveTeam(BuildContext context) async {
    final isSolo = _team != null && _team!.members.length <= 1;
    final hasOtherMembers = _team != null && _team!.members.length > 1;

    final l10n = AppLocalizations.of(context)!;
    // A leader cannot leave while other members are in the team —
    // they must transfer leadership first.
    if (_isLeader && hasOtherMembers) {
      _showSnackBar(context, l10n.transferLeadershipFirst);
      return;
    }

    // When the leader is the only member, leaving = deleting the team.
    // Make this explicit so the user understands what will happen.
    if (_isLeader && isSolo) {
      final confirmed = await _showConfirmDialog(
        context,
        title: l10n.leaveAndDelete,
        message: l10n.leaveAndDeleteDesc(_team!.name),
        confirmLabel: l10n.leaveAndDeleteButton,
        isDestructive: true,
      );
      if (confirmed != true || !mounted) return;
      unawaited(widget.teamCubit.delete(_team!.id));
      return;
    }

    // Regular member leaving.
    final confirmed = await _showConfirmDialog(
      context,
      title: l10n.leaveTeam,
      message: l10n.leaveTeamConfirm,
      confirmLabel: l10n.leave,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(widget.teamCubit.leave());
  }

  Future<void> _deleteTeam(BuildContext context) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      context,
      title: l10n.deleteTeam,
      message: l10n.deleteTeamDesc(_team!.name),
      confirmLabel: l10n.deleteTeam,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(widget.teamCubit.delete(_team!.id));
  }
}

// =============================================================================
// Browse Tab
// =============================================================================

class _BrowseTab extends StatefulWidget {
  const _BrowseTab({
    required this.searchCubit,
    required this.onSearchChanged,
  });

  final TeamsCubit searchCubit;
  final void Function(String) onSearchChanged;

  @override
  State<_BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<_BrowseTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBar(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _query = value);
            widget.onSearchChanged(value);
          },
        ),
        Expanded(
          child: BlocBuilder<TeamsCubit, TeamsState>(
            bloc: widget.searchCubit,
            builder: (context, state) {
              if (_query.trim().isEmpty) {
                return _buildIdlePrompt(context);
              }
              if (state is TeamsLoading) {
                return const Center(child: AppLoadingIndicator());
              }
              if (state is TeamsSearchResults) {
                if (state.teams.isEmpty) return _buildNoResults(context);
                return _buildResults(state.teams);
              }
              if (state is TeamsError) {
                return _buildError(context, state.message);
              }
              // Query entered but debounce hasn't fired yet.
              return const Center(child: AppLoadingIndicator(size: 40));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIdlePrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.secondary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 36,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.findATeam,
              style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.findATeamDesc,
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

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 52,
              color: context.colors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.noTeamsFound,
              style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.noTeamsMatchedQuery(_query),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return TeamCard(
          team: team,
          index: index,
          onTap: () => context.push('/teams/${team.id}'),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.colors.error,
            ),
            const SizedBox(height: AppSpacing.md),
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
// Reusable inner widgets
// =============================================================================

/// Gradient card at the top of the "My Team" tab showing the team name
/// and description with the app's purple accent palette.
class _TeamHeaderCard extends StatelessWidget {
  const _TeamHeaderCard({required this.team, required this.isLeader});

  final TeamEntity team;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: context.colors.secondary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative background circles
            const Positioned(
              top: -20,
              right: -16,
              child: _DecorCircle(size: 100, opacity: 0.08),
            ),
            const Positioned(
              top: 20,
              right: 40,
              child: _DecorCircle(size: 56, opacity: 0.1),
            ),
            const Positioned(
              bottom: -12,
              right: 80,
              child: _DecorCircle(size: 32, opacity: 0.06),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.group_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      if (isLeader)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 13,
                                color: context.colors.accentLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.leader,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    team.name,
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (team.description != null &&
                      team.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      team.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppLocalizations.of(context)!.memberCount(team.members.length),
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Members list section with an optional "Invite" button for leaders.
class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.team,
    required this.currentUserId,
    required this.isLeader,
    required this.onRemoveMember,
    required this.onInviteMember,
  });

  final TeamEntity team;
  final String? currentUserId;
  final bool isLeader;
  final void Function(String memberId) onRemoveMember;
  final VoidCallback onInviteMember;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.membersWithCount(team.members.length),
              style: AppTypography.labelLarge.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isLeader)
              _InviteButton(onTap: onInviteMember),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...team.members.asMap().entries.map((entry) {
          final member = entry.value;
          final isThisLeader = member.userId == team.leaderId;
          final isCurrentUser = member.userId == currentUserId;

          // Only the leader can remove non-leader members.
          final canRemove = isLeader && !isThisLeader;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TeamMemberTile(
              member: member,
              isLeader: isThisLeader,
              isCurrentUser: isCurrentUser,
              onRemove: canRemove ? () => onRemoveMember(member.userId) : null,
            ),
          );
        }),
      ],
    );
  }
}

/// Pending invitations received by the current user.
class _InvitationsSection extends StatelessWidget {
  const _InvitationsSection({
    required this.invitations,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
  });

  final List<InvitationEntity> invitations;
  final bool isLoading;
  final void Function(String id) onAccept;
  final void Function(String id) onDecline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.pendingInvitations,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isLoading && invitations.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppLoadingIndicator(size: 40),
            ),
          )
        else
          ...invitations.map(
            (invitation) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InvitationCard(
                invitation: invitation,
                onAccept: () => onAccept(invitation.id),
                onDecline: () => onDecline(invitation.id),
              ),
            ),
          ),
      ],
    );
  }
}

/// Leader-only settings section with grouped action rows.
class _TeamSettingsSection extends StatelessWidget {
  const _TeamSettingsSection({
    required this.onEdit,
    required this.onTransfer,
    required this.onDelete,
    required this.onLeave,
  });

  final VoidCallback onEdit;
  final VoidCallback onTransfer;
  final VoidCallback onDelete;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.teamSettings,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: context.colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.edit_outlined,
                iconColor: context.colors.secondary,
                title: AppLocalizations.of(context)!.editTeamInfo,
                subtitle: AppLocalizations.of(context)!.changeTeamNameDesc,
                onTap: onEdit,
              ),
              Divider(height: 1, indent: 56, color: context.colors.border),
              _SettingsTile(
                icon: Icons.swap_horiz_rounded,
                iconColor: context.colors.primary,
                title: AppLocalizations.of(context)!.transferLeadership,
                subtitle: AppLocalizations.of(context)!.assignNewLeader,
                onTap: onTransfer,
              ),
              Divider(height: 1, indent: 56, color: context.colors.border),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                iconColor: context.colors.error,
                title: AppLocalizations.of(context)!.deleteTeam,
                subtitle: AppLocalizations.of(context)!.permanentlyDisband,
                titleColor: context.colors.error,
                onTap: onDelete,
                showChevron: false,
              ),
              Divider(height: 1, indent: 56, color: context.colors.border),
              _SettingsTile(
                icon: Icons.exit_to_app_rounded,
                iconColor: context.colors.error,
                title: AppLocalizations.of(context)!.leaveTeam,
                subtitle: AppLocalizations.of(context)!.leaveTeamOnlyMember,
                titleColor: context.colors.error,
                onTap: onLeave,
                showChevron: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: titleColor ?? context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.colors.textHint,
              ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when the user has no team.
///
/// Shows pending invitations if any exist, then CTAs to create or browse.
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          _buildEmptyIllustration(context),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppLocalizations.of(context)!.notInTeamYet,
            style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.of(context)!.createOrJoinTeam,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            text: AppLocalizations.of(context)!.createATeam,
            onPressed: onCreateTeam,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBrowse,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.secondary,
                side: BorderSide(color: context.colors.secondary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.browseTeams),
            ),
          ),
          // Show pending invitations even when there's no team.
          if (invitations.isNotEmpty || isInvitationLoading) ...[
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.pendingInvitations,
                style: AppTypography.labelLarge.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...invitations.map(
              (inv) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InvitationCard(
                  invitation: inv,
                  onAccept: () => onAcceptInvitation(inv.id),
                  onDecline: () => onDeclineInvitation(inv.id),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildEmptyIllustration(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
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
          width: 80,
          height: 80,
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
            size: 36,
            color: context.colors.secondary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Small reusable widgets
// =============================================================================

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: context.colors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: context.colors.secondary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              AppLocalizations.of(context)!.invite,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyLarge.copyWith(
          color: context.colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchTeamsByName,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.colors.textHint,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: context.colors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}

/// Semi-transparent decorative circle used in the team header card.
class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// =============================================================================
// Dialog helpers (file-private)
// =============================================================================

Future<bool?> _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: AppTypography.h3.copyWith(color: ctx.colors.textPrimary),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: ctx.colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            AppLocalizations.of(ctx)!.cancel,
            style: AppTypography.labelMedium.copyWith(
              color: ctx.colors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel,
            style: AppTypography.labelMedium.copyWith(
              color: isDestructive ? ctx.colors.error : ctx.colors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<String?> _showInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
}) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: AppTypography.h3.copyWith(color: ctx.colors.textPrimary),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        style: AppTypography.bodyLarge.copyWith(color: ctx.colors.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            AppLocalizations.of(ctx)!.cancel,
            style: AppTypography.labelMedium.copyWith(
              color: ctx.colors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.of(ctx).pop(value);
          },
          child: Text(
            confirmLabel,
            style: AppTypography.labelMedium.copyWith(
              color: ctx.colors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<String?> _showMemberPickerSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<TeamMemberEntity> members,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: ctx.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: ctx.colors.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    color: ctx.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: ctx.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: ctx.colors.border),
          ...members.map(
            (m) => ListTile(
              leading: CircleAvatar(
                backgroundColor: ctx.colors.secondary.withValues(alpha: 0.15),
                child: Text(
                  m.userId.length >= 2
                      ? m.userId.substring(0, 2).toUpperCase()
                      : m.userId.toUpperCase(),
                  style: AppTypography.labelMedium.copyWith(
                    color: ctx.colors.secondary,
                    fontSize: 13,
                  ),
                ),
              ),
              title: Text(
                m.userId,
                style: AppTypography.labelMedium.copyWith(
                  color: ctx.colors.textPrimary,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: ctx.colors.textHint,
              ),
              onTap: () => Navigator.of(context).pop(m.userId),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
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
