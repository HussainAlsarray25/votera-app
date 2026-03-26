part of 'teams_cubit.dart';

abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object?> get props => [];
}

class TeamsInitial extends TeamsState {
  const TeamsInitial();
}

class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

class MyTeamsLoaded extends TeamsState {
  const MyTeamsLoaded({required this.teams});

  final List<TeamEntity> teams;

  @override
  List<Object?> get props => [teams];
}

class TeamLoaded extends TeamsState {
  const TeamLoaded({required this.team});

  final TeamEntity team;

  @override
  List<Object?> get props => [team];
}

class InvitationSent extends TeamsState {
  const InvitationSent({required this.invitation});

  final InvitationEntity invitation;

  @override
  List<Object?> get props => [invitation];
}

class InvitationsLoaded extends TeamsState {
  const InvitationsLoaded({required this.invitations});

  final List<InvitationEntity> invitations;

  @override
  List<Object?> get props => [invitations];
}

/// Emitted when a team search returns results.
class TeamsSearchResults extends TeamsState {
  const TeamsSearchResults({required this.teams});

  final List<TeamEntity> teams;

  @override
  List<Object?> get props => [teams];
}

/// Emitted after a successful void action (delete, leave, remove, respond, transfer).
class TeamsActionSuccess extends TeamsState {
  const TeamsActionSuccess();
}

/// Emitted when a mutation action (leave, remove, transfer, etc.) fails.
/// Unlike [TeamsError], this does NOT mean the team is gone — the cubit
/// preserves the loaded state and the UI should show an inline error message
/// (e.g. a snackbar) without wiping the team view.
class TeamsActionFailed extends TeamsState {
  const TeamsActionFailed({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class TeamsError extends TeamsState {
  const TeamsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
