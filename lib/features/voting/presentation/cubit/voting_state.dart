part of 'voting_cubit.dart';

abstract class VotingState extends Equatable {
  const VotingState();

  @override
  List<Object?> get props => [];
}

class VotingInitial extends VotingState {
  const VotingInitial();
}

class VotingLoading extends VotingState {
  const VotingLoading();
}

/// Emitted after the user's votes for an event are fetched successfully.
class VotesLoaded extends VotingState {
  const VotesLoaded({required this.votes});

  final List<VoteEntity> votes;

  @override
  List<Object?> get props => [votes];
}

/// Emitted after a vote is cast successfully.
class VoteCast extends VotingState {
  const VoteCast({required this.vote});

  final VoteEntity vote;

  @override
  List<Object?> get props => [vote];
}

/// Emitted after the tally for an event is fetched successfully.
class TallyLoaded extends VotingState {
  const TallyLoaded({required this.tally});

  final TallyEntity tally;

  @override
  List<Object?> get props => [tally];
}

/// Emitted after a vote is retracted successfully.
class VoteRetracted extends VotingState {
  const VoteRetracted();
}

class VotingError extends VotingState {
  const VotingError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted while the GPS location is being checked before voting.
class VotingLocationCheck extends VotingState {
  const VotingLocationCheck();
}

/// Emitted when the voting area polygon has been pre-fetched successfully.
class VotingAreaLoaded extends VotingState {
  const VotingAreaLoaded({required this.votingArea});

  final VotingAreaEntity votingArea;

  @override
  List<Object?> get props => [votingArea];
}

/// Emitted when the user is outside the allowed voting area.
class OutsideVotingArea extends VotingState {
  const OutsideVotingArea({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when GPS position could not be obtained (permissions or service).
class LocationUnavailable extends VotingState {
  const LocationUnavailable({
    required this.message,
    this.isDeniedForever = false,
  });

  final String message;
  final bool isDeniedForever;

  @override
  List<Object?> get props => [message, isDeniedForever];
}
