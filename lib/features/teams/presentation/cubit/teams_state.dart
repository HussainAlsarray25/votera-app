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

/// Emitted after a successful void action (delete, leave, remove, respond, transfer).
class TeamsActionSuccess extends TeamsState {
  const TeamsActionSuccess();
}

class TeamsError extends TeamsState {
  const TeamsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
