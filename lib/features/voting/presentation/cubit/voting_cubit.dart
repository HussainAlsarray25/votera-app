import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/usecases/cast_vote.dart';
import 'package:votera/features/voting/domain/usecases/get_event_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_my_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_vote_tally.dart';
import 'package:votera/features/voting/domain/usecases/retract_vote.dart';

part 'voting_state.dart';

/// Manages all voting actions for an event: casting, fetching, tallying, and
/// retracting votes.
class VotingCubit extends Cubit<VotingState> {
  VotingCubit({
    required this.castVote,
    required this.getMyVotes,
    required this.getVoteTally,
    required this.retractVote,
    required this.getEventVotes,
  }) : super(const VotingInitial());

  final CastVote castVote;
  final GetMyVotes getMyVotes;
  final GetVoteTally getVoteTally;
  final RetractVote retractVote;
  final GetEventVotes getEventVotes;

  Future<void> loadMyVotes({required String eventId}) async {
    emit(const VotingLoading());
    final result = await getMyVotes(GetMyVotesParams(eventId: eventId));
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (votes) => emit(VotesLoaded(votes: votes)),
    );
  }

  Future<void> submitVote({
    required String eventId,
    required String projectId,
  }) async {
    emit(const VotingLoading());
    final result = await castVote(
      CastVoteParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (vote) => emit(VoteCast(vote: vote)),
    );
  }

  Future<void> loadTally({required String eventId}) async {
    emit(const VotingLoading());
    final result = await getVoteTally(GetVoteTallyParams(eventId: eventId));
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (tally) => emit(TallyLoaded(tally: tally)),
    );
  }

  Future<void> removeVote({
    required String eventId,
    required String voteId,
  }) async {
    emit(const VotingLoading());
    final result = await retractVote(
      RetractVoteParams(eventId: eventId, voteId: voteId),
    );
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (_) => emit(const VoteRetracted()),
    );
  }

  Future<void> loadEventVotes({required String eventId}) async {
    emit(const VotingLoading());
    final result = await getEventVotes(
      GetEventVotesParams(eventId: eventId),
    );
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (votes) => emit(VotesLoaded(votes: votes)),
    );
  }
}
