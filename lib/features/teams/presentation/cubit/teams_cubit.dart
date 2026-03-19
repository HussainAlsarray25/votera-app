import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/usecases/create_team.dart';
import 'package:votera/features/teams/domain/usecases/delete_team.dart';
import 'package:votera/features/teams/domain/usecases/get_my_invitations.dart';
import 'package:votera/features/teams/domain/usecases/get_my_team.dart';
import 'package:votera/features/teams/domain/usecases/get_team.dart';
import 'package:votera/features/teams/domain/usecases/invite_member.dart';
import 'package:votera/features/teams/domain/usecases/leave_team.dart';
import 'package:votera/features/teams/domain/usecases/remove_member.dart';
import 'package:votera/features/teams/domain/usecases/cancel_invitation.dart';
import 'package:votera/features/teams/domain/usecases/respond_to_invitation.dart';
import 'package:votera/features/teams/domain/usecases/search_teams.dart';
import 'package:votera/features/teams/domain/usecases/transfer_leadership.dart';
import 'package:votera/features/teams/domain/usecases/update_team.dart';

part 'teams_state.dart';

/// Manages all team-related state transitions.
class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit({
    required this.createTeam,
    required this.getTeam,
    required this.getMyTeam,
    required this.updateTeam,
    required this.deleteTeam,
    required this.inviteMember,
    required this.getMyInvitations,
    required this.respondToInvitation,
    required this.leaveTeam,
    required this.removeMember,
    required this.transferLeadership,
    required this.searchTeams,
    required this.cancelInvitation,
  }) : super(const TeamsInitial());

  final CreateTeam createTeam;
  final GetTeam getTeam;
  final GetMyTeam getMyTeam;
  final UpdateTeam updateTeam;
  final DeleteTeam deleteTeam;
  final InviteMember inviteMember;
  final GetMyInvitations getMyInvitations;
  final RespondToInvitation respondToInvitation;
  final LeaveTeam leaveTeam;
  final RemoveMember removeMember;
  final TransferLeadership transferLeadership;
  final SearchTeams searchTeams;
  final CancelInvitation cancelInvitation;

  Future<void> create({required String name, String? description}) async {
    emit(const TeamsLoading());
    final result = await createTeam(
      CreateTeamParams(name: name, description: description),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (team) => emit(TeamLoaded(team: team)),
    );
  }

  Future<void> loadTeam(String teamId) async {
    emit(const TeamsLoading());
    final result = await getTeam(GetTeamParams(teamId: teamId));
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (team) => emit(TeamLoaded(team: team)),
    );
  }

  Future<void> loadMyTeam() async {
    emit(const TeamsLoading());
    final result = await getMyTeam(NoParams());
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (team) => emit(TeamLoaded(team: team)),
    );
  }

  Future<void> update({
    required String teamId,
    String? name,
    String? description,
  }) async {
    emit(const TeamsLoading());
    final result = await updateTeam(
      UpdateTeamParams(teamId: teamId, name: name, description: description),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (team) => emit(TeamLoaded(team: team)),
    );
  }

  Future<void> delete(String teamId) async {
    emit(const TeamsLoading());
    final result = await deleteTeam(DeleteTeamParams(teamId: teamId));
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (_) => emit(const TeamsActionSuccess()),
    );
  }

  Future<void> invite({
    required String teamId,
    required String inviteeId,
  }) async {
    emit(const TeamsLoading());
    final result = await inviteMember(
      InviteMemberParams(teamId: teamId, inviteeId: inviteeId),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (invitation) => emit(InvitationSent(invitation: invitation)),
    );
  }

  Future<void> loadInvitations() async {
    emit(const TeamsLoading());
    final result = await getMyInvitations(NoParams());
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (invitations) => emit(InvitationsLoaded(invitations: invitations)),
    );
  }

  Future<void> respond({
    required String invitationId,
    required bool accept,
  }) async {
    emit(const TeamsLoading());
    final result = await respondToInvitation(
      RespondToInvitationParams(invitationId: invitationId, accept: accept),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (_) => emit(const TeamsActionSuccess()),
    );
  }

  Future<void> leave() async {
    emit(const TeamsLoading());
    final result = await leaveTeam(NoParams());
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (_) => emit(const TeamsActionSuccess()),
    );
  }

  Future<void> remove({
    required String teamId,
    required String memberId,
  }) async {
    emit(const TeamsLoading());
    final result = await removeMember(
      RemoveMemberParams(teamId: teamId, memberId: memberId),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (_) => emit(const TeamsActionSuccess()),
    );
  }

  Future<void> transfer({
    required String teamId,
    required String newLeaderId,
  }) async {
    emit(const TeamsLoading());
    final result = await transferLeadership(
      TransferLeadershipParams(teamId: teamId, newLeaderId: newLeaderId),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (_) => emit(const TeamsActionSuccess()),
    );
  }

  Future<void> search({required String query}) async {
    emit(const TeamsLoading());
    final result = await searchTeams(SearchTeamsParams(query: query));
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (teams) => emit(TeamsSearchResults(teams: teams)),
    );
  }

  Future<void> revokeInvitation({required String invitationId}) async {
    emit(const TeamsLoading());
    final result = await cancelInvitation(
      CancelInvitationParams(invitationId: invitationId),
    );
    result.fold(
      (failure) => emit(TeamsError(message: failure.message)),
      (_) => emit(const TeamsActionSuccess()),
    );
  }
}
