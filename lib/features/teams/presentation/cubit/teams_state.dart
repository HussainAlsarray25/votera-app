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
/// Includes pagination metadata so the UI can implement load-more if needed.
class TeamsSearchResults extends TeamsState {
  const TeamsSearchResults({
    required this.teams,
    required this.page,
    required this.total,
    required this.hasNextPage,
  });

  final List<TeamEntity> teams;
  final int page;
  final int total;
  final bool hasNextPage;

  @override
  List<Object?> get props => [teams, page, total, hasNextPage];
}

/// Emitted when join requests for a team are loaded (leader only).
class JoinRequestsLoaded extends TeamsState {
  const JoinRequestsLoaded({required this.requests});

  final List<JoinRequestEntity> requests;

  @override
  List<Object?> get props => [requests];
}

/// Emitted after the current user successfully sends a join request.
class JoinRequestSent extends TeamsState {
  const JoinRequestSent({required this.request});

  final JoinRequestEntity request;

  @override
  List<Object?> get props => [request];
}

/// Emitted while the team image is being uploaded to S3.
/// The UI should show a loading overlay on the avatar without wiping the page.
class TeamsImageUploading extends TeamsState {
  const TeamsImageUploading();
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
