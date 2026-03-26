import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';
import 'package:votera/features/teams/presentation/widgets/create_edit_team_sheet.dart';
import 'package:votera/features/teams/presentation/widgets/team_member_tile.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
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
    } else if (state is TeamsError) {
      _showSnackBar(context, state.message);
    }
  }

  void _onActionState(BuildContext context, TeamsState state) {
    switch (state) {
      case TeamsActionSuccess():
        // Reload the team so the UI reflects the latest server state.
        unawaited(_loadCubit.loadTeam(widget.teamId));

      case TeamsActionFailed():
        _showSnackBar(context, state.message);

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
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          team.name,
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
        // Leader-only three-dot menu in the app bar.
        actions: [
          if (_isLeader)
            PopupMenuButton<_TeamAction>(
              icon: Icon(Icons.more_vert_rounded, color: context.colors.textPrimary),
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
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadCubit.loadTeam(widget.teamId),
        color: context.colors.secondary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _TeamHeaderCard(team: team, isLeader: _isLeader),
            const SizedBox(height: AppSpacing.md),
            if (team.description != null && team.description!.isNotEmpty) ...[
              _DescriptionCard(description: team.description!),
              const SizedBox(height: AppSpacing.md),
            ],
            _MembersCard(
              team: team,
              currentUserId: _currentUserId,
              isLeader: _isLeader,
              onRemoveMember: _isMember
                  ? (memberId) => _removeMember(context, memberId)
                  : null,
              onInviteMember: _isLeader ? () => _inviteMember(context) : null,
            ),
            // Regular member: show leave button at the bottom.
            if (!_isLeader && _isMember) ...[
              const SizedBox(height: AppSpacing.lg),
              Divider(color: context.colors.border),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _leaveTeam(context),
                  icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                  label: Text(l10n.leaveTeam),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
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
    final inviteeEmail = await _showInputDialog(
      context,
      title: l10n.inviteMember,
      hint: l10n.enterUserIdToInvite,
      confirmLabel: l10n.sendInvite,
    );
    if (inviteeEmail == null || !mounted) return;
    unawaited(
      _actionCubit.invite(teamId: _team!.id, inviteeEmail: inviteeEmail),
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
      final confirmed = await _showConfirmDialog(
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

    final confirmed = await _showConfirmDialog(
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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 52,
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
              const SizedBox(height: AppSpacing.md),
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

/// Team header card shown at the top of the scrollable content area.
/// Team header card — centered layout with avatar, name, stats, and ID chip.
class _TeamHeaderCard extends StatelessWidget {
  const _TeamHeaderCard({required this.team, required this.isLeader});

  final TeamEntity team;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          // Avatar + name + badge — identity block.
          Container(
            width: 100,
            height: 100,
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
              border: Border.all(
                color: context.colors.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                style: AppTypography.h3.copyWith(
                  color: context.colors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            team.name,
            style: AppTypography.h3.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isLeader) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: context.colors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      size: 12, color: context.colors.accent),
                  const SizedBox(width: 4),
                  Text(
                    l10n.leader,
                    style: AppTypography.caption.copyWith(
                      color: context.colors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.border, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Stats block — each stat in its own equal-width cell.
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.group_outlined,
                    value: '${team.members.length}',
                    label: l10n.memberCount(team.members.length),
                  ),
                ),
                if (team.createdAt != null) ...[
                  VerticalDivider(
                    color: context.colors.border,
                    width: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    child: _StatCell(
                      icon: Icons.calendar_today_outlined,
                      value: _formatDate(team.createdAt!),
                      label: l10n.createdAt,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Handle chip — centered, tappable to copy.
          if (team.handle != null || team.id.isNotEmpty)
            GestureDetector(
              onTap: () => _copyId(context, team.handle ?? team.id),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tag_rounded,
                        size: 16, color: context.colors.textHint),
                    const SizedBox(width: 5),
                    Text(
                      team.handle ?? team.id,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textHint,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.copy_rounded,
                        size: 16, color: context.colors.textHint),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _copyId(BuildContext context, String id) {
    Clipboard.setData(ClipboardData(text: id));
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
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
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: effectiveColor),
        ),
      ],
    );
  }
}

/// A centered stat cell used in the header card stats row.
/// Shows an icon + value on top and a smaller label below.
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: context.colors.secondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.colors.textHint,
          ),
        ),
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.about,
            style: AppTypography.labelLarge.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
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
  });

  final TeamEntity team;
  final String? currentUserId;
  final bool isLeader;
  final void Function(String memberId)? onRemoveMember;
  final VoidCallback? onInviteMember;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.membersWithCount(team.members.length),
              style: AppTypography.labelLarge.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const Spacer(),
            if (onInviteMember != null)
              TextButton.icon(
                onPressed: onInviteMember,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(l10n.invite),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.secondary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...team.members.map(
          (member) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
    );
  }
}

// =============================================================================
// Dialog helpers
// =============================================================================

Future<bool?> _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDestructive = false,
}) {
  final colors = Theme.of(context).extension<AppColorScheme>()!;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor:
                isDestructive ? colors.error : colors.secondary,
          ),
          child: Text(confirmLabel),
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
  final colors = Theme.of(context).extension<AppColorScheme>()!;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          style: TextButton.styleFrom(foregroundColor: colors.secondary),
          child: Text(confirmLabel),
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
    isScrollControlled: true,
    backgroundColor: Theme.of(context).extension<AppColorScheme>()!.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
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
              padding: const EdgeInsets.all(AppSpacing.md),
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
                  const SizedBox(height: 4),
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
            const SizedBox(height: AppSpacing.md),
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
