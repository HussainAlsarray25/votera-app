import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/teams/domain/entities/join_request_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/create_edit_team_sheet.dart';
import 'package:votera/features/teams/presentation/widgets/team_member_tile.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_dialog.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';

/// Full team detail page, navigated to from both the My Team tab and Browse tab.
///
/// - If the current user is the team leader, management actions are shown
///   (edit, invite, transfer leadership, delete).
/// - If the current user is a regular member, a leave option is shown.
/// - If the current user is not a member, the page is read-only.
class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({required this.teamId, super.key});

  final String teamId;

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  // Two cubits: one for loading/displaying, one for mutation actions.
  // This prevents a mutation's loading state from wiping the displayed team.
  late final TeamsCubit _loadCubit;
  late final TeamsCubit _actionCubit;

  TeamEntity? _team;
  List<JoinRequestEntity> _joinRequests = [];
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCubit = sl<TeamsCubit>();
    _actionCubit = sl<TeamsCubit>();
    unawaited(_loadCubit.loadTeam(widget.teamId));
  }

  @override
  void dispose() {
    unawaited(_loadCubit.close());
    unawaited(_actionCubit.close());
    super.dispose();
  }

  String? get _currentUserId {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) return state.profile.id;
    return null;
  }

  bool get _isLeader =>
      _team != null && _currentUserId != null && _team!.leaderId == _currentUserId;

  bool get _isMember =>
      _team != null &&
      _currentUserId != null &&
      _team!.members.any((m) => m.userId == _currentUserId);

  void _onLoadState(BuildContext context, TeamsState state) {
    if (state is TeamLoaded) {
      setState(() => _team = state.team);
      // Once the team is loaded, fetch join requests if the current user is the leader.
      if (_isLeader) {
        unawaited(_actionCubit.loadJoinRequests(widget.teamId));
      }
    } else if (state is TeamsError) {
      _showSnackBar(context, state.message);
    }
  }

  void _onActionState(BuildContext context, TeamsState state) {
    switch (state) {
      case TeamsActionSuccess():
        // Reload both the team and the join requests list.
        setState(() => _isImageUploading = false);
        unawaited(_loadCubit.loadTeam(widget.teamId));
        if (_isLeader) {
          unawaited(_actionCubit.loadJoinRequests(widget.teamId));
        }

      case TeamsActionFailed():
        setState(() => _isImageUploading = false);
        _showSnackBar(context, state.message);

      case TeamsImageUploading():
        setState(() => _isImageUploading = true);

      case JoinRequestsLoaded():
        setState(() => _joinRequests = state.requests);

      case JoinRequestSent():
        _showSnackBar(context, AppLocalizations.of(context)!.joinRequestSent);

      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TeamsCubit, TeamsState>(
          bloc: _loadCubit,
          listener: _onLoadState,
        ),
        BlocListener<TeamsCubit, TeamsState>(
          bloc: _actionCubit,
          listener: _onActionState,
        ),
      ],
      child: BlocBuilder<TeamsCubit, TeamsState>(
        bloc: _loadCubit,
        builder: (context, state) {
          if (_team == null) {
            if (state is TeamsError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => unawaited(_loadCubit.loadTeam(widget.teamId)),
              );
            }
            return const _LoadingView();
          }
          return _buildContent(context, _team!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TeamEntity team) {
    final l10n = AppLocalizations.of(context)!;
    final isRoyal = team.name == 'Frogs Team';
    // The hero gradient adapts to the royal team or falls back to the app palette.
    final heroGradient = isRoyal
        ? const [Color(0xFF1A0045), Color(0xFF5B0092)]
        : [context.colors.primary, context.colors.secondary];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: CenteredContent(
        maxWidth: 900,
        child: RefreshIndicator(
          onRefresh: () async => _loadCubit.loadTeam(widget.teamId),
          color: context.colors.secondary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Gradient hero app bar — collapses to show only the team name.
              SliverAppBar(
                expandedHeight: 230.h,
                pinned: true,
                stretch: true,
                backgroundColor: heroGradient.first,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  team.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Leader-only three-dot menu — white icon to contrast the hero.
                actions: [
                  if (_isLeader)
                    PopupMenuButton<_TeamAction>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                      ),
                      color: context.colors.surface,
                      onSelected: (action) {
                        switch (action) {
                          case _TeamAction.edit:
                            _editTeam(context);
                          case _TeamAction.transfer:
                            _transferLeadership(context);
                          case _TeamAction.leave:
                            _leaveTeam(context);
                          case _TeamAction.delete:
                            _deleteTeam(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _TeamAction.edit,
                          child: _MenuRow(
                            icon: Icons.edit_rounded,
                            label: l10n.editTeamInfo,
                          ),
                        ),
                        PopupMenuItem(
                          value: _TeamAction.transfer,
                          child: _MenuRow(
                            icon: Icons.swap_horiz_rounded,
                            label: l10n.transferLeadership,
                          ),
                        ),
                        PopupMenuItem(
                          value: _TeamAction.leave,
                          child: _MenuRow(
                            icon: Icons.exit_to_app_rounded,
                            label: l10n.leaveTeam,
                            color: context.colors.error,
                          ),
                        ),
                        PopupMenuItem(
                          value: _TeamAction.delete,
                          child: _MenuRow(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.deleteTeam,
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  collapseMode: CollapseMode.parallax,
                  background: _TeamHeroBackground(
                    team: team,
                    isLeader: _isLeader,
                    isRoyal: isRoyal,
                    gradient: heroGradient,
                    isImageUploading: _isImageUploading,
                    onPickImage: _isLeader
                        ? () => _pickAndUploadImage(context)
                        : null,
                    onDeleteImage: _isLeader && team.imageUrl != null
                        ? () => _deleteImage(context)
                        : null,
                  ),
                ),
              ),

              // Scrollable content below the hero.
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stat pills — member count, creation date, and handle.
                    _StatsRow(team: team, isRoyal: isRoyal),
                    SizedBox(height: AppSpacing.md),
                    // About section.
                    if (team.description != null &&
                        team.description!.isNotEmpty) ...[
                      _SectionCard(
                        title: l10n.about,
                        accentColor: isRoyal
                            ? const Color(0xFFFFD700)
                            : context.colors.secondary,
                        child: Text(
                          team.description!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                    // Members section.
                    _MembersCard(
                      team: team,
                      currentUserId: _currentUserId,
                      isLeader: _isLeader,
                      isRoyal: isRoyal,
                      onRemoveMember: _isMember
                          ? (memberId) => _removeMember(context, memberId)
                          : null,
                      onInviteMember:
                          _isLeader ? () => _inviteMember(context) : null,
                    ),
                    // Join requests (leader only).
                    if (_isLeader) ...[
                      SizedBox(height: AppSpacing.md),
                      _JoinRequestsCard(
                        requests: _joinRequests,
                        isRoyal: isRoyal,
                        onApprove: (req) => unawaited(
                          _actionCubit.respondToJoinRequest(
                            teamId: team.id,
                            requestId: req.id,
                            approve: true,
                          ),
                        ),
                        onDecline: (req) => unawaited(
                          _actionCubit.respondToJoinRequest(
                            teamId: team.id,
                            requestId: req.id,
                            approve: false,
                          ),
                        ),
                      ),
                    ],
                    // Non-member: request to join.
                    if (!_isMember) ...[
                      SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _requestToJoin(context),
                          icon: Icon(
                            Icons.person_add_outlined,
                            size: AppSizes.iconSm,
                          ),
                          label: Text(l10n.requestToJoin),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.secondary,
                            foregroundColor: context.colors.textOnPrimary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Regular member: leave button.
                    if (!_isLeader && _isMember) ...[
                      SizedBox(height: AppSpacing.lg),
                      Divider(color: context.colors.border),
                      SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _leaveTeam(context),
                          icon: Icon(
                            Icons.exit_to_app_rounded,
                            size: AppSizes.iconSm,
                          ),
                          label: Text(l10n.leaveTeam),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.error,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _editTeam(BuildContext context) async {
    if (_team == null) return;
    final result = await showCreateEditTeamSheet(
      context,
      initialName: _team!.name,
      initialDescription: _team!.description,
    );
    if (result == null || !mounted) return;
    unawaited(
      _actionCubit.update(
        teamId: _team!.id,
        name: result.name,
        description: result.description,
      ),
    );
  }

  Future<void> _inviteMember(BuildContext context) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final inviteeHandle = await showAppInputDialog(
      context,
      title: l10n.inviteMember,
      hint: l10n.enterUserIdToInvite,
      confirmLabel: l10n.sendInvite,
    );
    if (inviteeHandle == null || inviteeHandle.isEmpty || !mounted) return;
    unawaited(
      _actionCubit.invite(teamId: _team!.id, inviteeHandle: inviteeHandle),
    );
  }

  Future<void> _requestToJoin(BuildContext context) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final message = await showAppInputDialog(
      context,
      title: l10n.requestToJoin,
      hint: l10n.joinRequestMessageHint,
      confirmLabel: l10n.requestToJoin,
    );
    // A null result means the user tapped Cancel — an empty string is valid (no message).
    if (message == null || !mounted) return;
    unawaited(
      _actionCubit.requestToJoin(
        teamId: _team!.id,
        message: message.isEmpty ? null : message,
      ),
    );
  }

  Future<void> _removeMember(BuildContext context, String memberId) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.removeMember,
      message: l10n.removeMemberConfirm,
      confirmLabel: l10n.remove,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(
      _actionCubit.remove(teamId: _team!.id, memberId: memberId),
    );
  }

  Future<void> _transferLeadership(BuildContext context) async {
    if (_team == null) return;
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
      _actionCubit.transfer(teamId: _team!.id, newLeaderId: newLeaderId),
    );
  }

  Future<void> _leaveTeam(BuildContext context) async {
    if (_team == null) return;
    final isSolo = _team!.members.length <= 1;
    final hasOtherMembers = _team!.members.length > 1;
    final l10n = AppLocalizations.of(context)!;

    // A leader cannot leave while other members are in the team.
    if (_isLeader && hasOtherMembers) {
      _showSnackBar(context, l10n.transferLeadershipFirst);
      return;
    }

    // When the leader is the only member, leaving = deleting the team.
    if (_isLeader && isSolo) {
      final confirmed = await showAppConfirmDialog(
        context,
        title: l10n.leaveAndDelete,
        message: l10n.leaveAndDeleteDesc(_team!.name),
        confirmLabel: l10n.leaveAndDeleteButton,
        isDestructive: true,
      );
      if (confirmed != true || !mounted) return;
      unawaited(_actionCubit.delete(_team!.id));
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.leaveTeam,
      message: l10n.leaveTeamConfirm,
      confirmLabel: l10n.leave,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(_actionCubit.leave(teamId: _team!.id));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    if (_team == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // withData ensures we get in-memory bytes on all platforms (web, mobile, desktop).
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    unawaited(
      _actionCubit.uploadImage(
        teamId: _team!.id,
        fileName: file.name,
        bytes: file.bytes!,
      ),
    );
  }

  Future<void> _deleteImage(BuildContext context) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteTeamImage,
      message: l10n.deleteTeamImageConfirm,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(_actionCubit.removeTeamImage(_team!.id));
  }

  Future<void> _deleteTeam(BuildContext context) async {
    if (_team == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteTeam,
      message: l10n.deleteTeamDesc(_team!.name),
      confirmLabel: l10n.deleteTeam,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    unawaited(_actionCubit.delete(_team!.id));
    if (mounted) Navigator.of(context).pop();
  }
}

// Enum for the popup menu actions available to team leaders.
enum _TeamAction { edit, transfer, leave, delete }

// =============================================================================
// Views
// =============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: const Center(child: AppLoadingIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(backgroundColor: context.colors.surface),
      body: Center(
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
              SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Inner widgets
// =============================================================================

// The hero gradient background shown inside the SliverAppBar flexible space.
class _TeamHeroBackground extends StatelessWidget {
  const _TeamHeroBackground({
    required this.team,
    required this.isLeader,
    required this.isRoyal,
    required this.gradient,
    this.isImageUploading = false,
    this.onPickImage,
    this.onDeleteImage,
  });

  final TeamEntity team;
  final bool isLeader;
  final bool isRoyal;
  final List<Color> gradient;
  final bool isImageUploading;
  final VoidCallback? onPickImage;
  final VoidCallback? onDeleteImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
        ),
        // Decorative background circles for depth.
        Positioned(top: -30, right: -20, child: _HeroCircle(size: 200.r, opacity: 0.07)),
        Positioned(top: 60, right: 80, child: _HeroCircle(size: 80.r, opacity: 0.06)),
        Positioned(bottom: -30, left: 20, child: _HeroCircle(size: 140.r, opacity: 0.05)),
        // Extra golden shimmer orb for the royal team.
        if (isRoyal)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 130.r,
              height: 130.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.22),
                    const Color(0xFFFFD700).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        // Centered: avatar, team name, leader badge.
        Padding(
          padding: EdgeInsets.only(top: 48.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar circle — shows uploaded image, uploading spinner, or fallback initials/crown.
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring with border and shadow.
                  Container(
                    width: 82.r,
                    height: 82.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isRoyal
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.5),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        if (isRoyal)
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            blurRadius: 24,
                          ),
                      ],
                    ),
                    child: ClipOval(
                      child: isImageUploading
                          // Show a spinner while the upload is in progress.
                          ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : team.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: team.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => _AvatarFallback(
                                    team: team,
                                    isRoyal: isRoyal,
                                  ),
                                )
                              : _AvatarFallback(team: team, isRoyal: isRoyal),
                    ),
                  ),
                  // Camera overlay — lets the leader tap to change the photo.
                  if (onPickImage != null && !isImageUploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onPickImage,
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 14.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Delete image button — shown when an image exists and not uploading.
                  if (onDeleteImage != null && !isImageUploading)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onDeleteImage,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withValues(alpha: 0.75),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 12.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              // Team name.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  team.name,
                  style: AppTypography.h3.copyWith(
                    color: isRoyal ? const Color(0xFFFFD700) : Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: isRoyal
                        ? [
                            Shadow(
                              color:
                                  const Color(0xFFFFD700).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Leader badge shown below the name.
              if (isLeader) ...[
                SizedBox(height: AppSpacing.xs),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: isRoyal
                          ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: AppSizes.iconXs,
                        color: isRoyal
                            ? const Color(0xFFFFD700)
                            : Colors.white,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.leader,
                        style: AppTypography.caption.copyWith(
                          color: isRoyal
                              ? const Color(0xFFFFD700)
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Fallback avatar content shown when no image has been uploaded.
// Displays a crown emoji for the royal team or the team name's first letter.
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.team, required this.isRoyal});

  final TeamEntity team;
  final bool isRoyal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isRoyal
          // Crown emoji for the royal team — same as on the rankings podium.
          ? Text('\u{1F451}', style: TextStyle(fontSize: 38.sp))
          : Text(
              team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
              style: AppTypography.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

// A white semi-transparent circle used as a decorative background element.
class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size, required this.opacity});

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

// A reusable section card with a gradient left accent bar, a title row,
// an optional trailing widget, and arbitrary child content.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.accentColor,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Color? accentColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? context.colors.primary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with gradient left bar.
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 4.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(color: context.colors.border, height: 1),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Horizontal row of stat pills — member count, creation date, and handle.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.team, required this.isRoyal});

  final TeamEntity team;
  final bool isRoyal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor =
        isRoyal ? const Color(0xFFB8860B) : context.colors.primary;
    final handle = team.handle ?? (team.id.isNotEmpty ? team.id : null);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatPill(
          icon: Icons.group_rounded,
          label: l10n.memberCount(team.members.length),
          color: accentColor,
        ),
        if (team.createdAt != null)
          _StatPill(
            icon: Icons.calendar_today_rounded,
            label: _formatDate(team.createdAt!),
            color: context.colors.textHint,
          ),
        if (handle != null)
          _HandleChip(handle: handle, isRoyal: isRoyal),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// A single pill chip showing an icon and a label.
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Team handle/ID chip — tappable to copy the handle to clipboard.
class _HandleChip extends StatelessWidget {
  const _HandleChip({required this.handle, this.isRoyal = false});

  final String handle;
  final bool isRoyal;

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: handle));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        isRoyal ? const Color(0xFFB8860B) : context.colors.textHint;
    return GestureDetector(
      onTap: () => _copy(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isRoyal
                ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                : context.colors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag_rounded, size: 14.r, color: textColor),
            SizedBox(width: 6.w),
            Text(
              handle,
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.copy_rounded, size: 14.r, color: context.colors.textHint),
          ],
        ),
      ),
    );
  }
}

/// A row used inside the popup menu, with an icon and label.
class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: effectiveColor),
        SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: effectiveColor),
        ),
      ],
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.team,
    required this.currentUserId,
    required this.isLeader,
    required this.onRemoveMember,
    required this.onInviteMember,
    this.isRoyal = false,
  });

  final TeamEntity team;
  final String? currentUserId;
  final bool isLeader;
  final bool isRoyal;
  final void Function(String memberId)? onRemoveMember;
  final VoidCallback? onInviteMember;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.membersWithCount(team.members.length),
      accentColor:
          isRoyal ? const Color(0xFFFFD700) : context.colors.secondary,
      trailing: onInviteMember != null
          ? TextButton.icon(
              onPressed: onInviteMember,
              icon: Icon(Icons.person_add_rounded, size: AppSizes.iconSm),
              label: Text(l10n.invite),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.secondary,
                visualDensity: VisualDensity.compact,
              ),
            )
          : null,
      child: Column(
        children: [
          ...team.members.map(
            (member) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: TeamMemberTile(
                member: member,
                isLeader: member.userId == team.leaderId,
                // Leaders can remove anyone except themselves.
                onRemove: isLeader && member.userId != currentUserId
                    ? () => onRemoveMember?.call(member.userId)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card displayed to team leaders listing all pending join requests.
/// Each row shows the requesting user's handle and approve/decline buttons.
class _JoinRequestsCard extends StatelessWidget {
  const _JoinRequestsCard({
    required this.requests,
    required this.onApprove,
    required this.onDecline,
    this.isRoyal = false,
  });

  final List<JoinRequestEntity> requests;
  final void Function(JoinRequestEntity) onApprove;
  final void Function(JoinRequestEntity) onDecline;
  final bool isRoyal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Badge showing the pending count in the section header.
    final countBadge = requests.isNotEmpty
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: context.colors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '${requests.length}',
              style: AppTypography.caption.copyWith(
                color: context.colors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        : null;

    return _SectionCard(
      title: l10n.joinRequests,
      accentColor:
          isRoyal ? const Color(0xFFFFD700) : context.colors.secondary,
      trailing: countBadge,
      child: requests.isEmpty
          ? Text(
              l10n.noJoinRequests,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textHint,
              ),
            )
          : Column(
              children: [
                ...requests.map(
                  (req) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _JoinRequestTile(
                      request: req,
                      onApprove: () => onApprove(req),
                      onDecline: () => onDecline(req),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _JoinRequestTile extends StatelessWidget {
  const _JoinRequestTile({
    required this.request,
    required this.onApprove,
    required this.onDecline,
  });

  final JoinRequestEntity request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: context.colors.secondary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_outline_rounded,
              size: AppSizes.iconSm,
              color: context.colors.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userId,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (request.message != null && request.message!.isNotEmpty)
                  Text(
                    request.message!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          // Decline button
          IconButton(
            onPressed: onDecline,
            icon: Icon(
              Icons.close_rounded,
              color: context.colors.error,
              size: AppSizes.iconSm,
            ),
            tooltip: l10n.declineRequest,
            visualDensity: VisualDensity.compact,
          ),
          // Approve button
          IconButton(
            onPressed: onApprove,
            icon: Icon(
              Icons.check_rounded,
              color: context.colors.secondary,
              size: AppSizes.iconSm,
            ),
            tooltip: l10n.approveRequest,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

Future<String?> _showMemberPickerSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<TeamMemberEntity> members,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).extension<AppColorScheme>()!.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<AppColorScheme>()!
                    .border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: Theme.of(context)
                          .extension<AppColorScheme>()!
                          .textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context)
                          .extension<AppColorScheme>()!
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .extension<AppColorScheme>()!
                        .primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      member.displayName.isNotEmpty
                          ? member.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<AppColorScheme>()!
                            .primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(member.displayName),
                  onTap: () => Navigator.of(context).pop(member.userId),
                );
              },
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      );
    },
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
