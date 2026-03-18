import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class RetractVote extends UseCase<void, RetractVoteParams> {
  RetractVote(this.repository);

  final VotingRepository repository;

  @override
  Future<Either<Failure, void>> call(RetractVoteParams params) {
    return repository.retractVote(
      eventId: params.eventId,
      voteId: params.voteId,
    );
  }
}

class RetractVoteParams extends Equatable {
  const RetractVoteParams({
    required this.eventId,
    required this.voteId,
  });

  final String eventId;
  final String voteId;

  @override
  List<Object?> get props => [eventId, voteId];
}
