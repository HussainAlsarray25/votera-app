import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class GetVoteTally extends UseCase<TallyEntity, GetVoteTallyParams> {
  GetVoteTally(this.repository);

  final VotingRepository repository;

  @override
  Future<Either<Failure, TallyEntity>> call(GetVoteTallyParams params) {
    return repository.getVoteTally(eventId: params.eventId);
  }
}

class GetVoteTallyParams extends Equatable {
  const GetVoteTallyParams({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}
