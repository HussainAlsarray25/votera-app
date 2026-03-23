import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/voting/domain/entities/voting_area_entity.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class GetVotingArea extends UseCase<VotingAreaEntity, GetVotingAreaParams> {
  GetVotingArea(this.repository);

  final VotingRepository repository;

  @override
  Future<Either<Failure, VotingAreaEntity>> call(GetVotingAreaParams params) {
    return repository.getVotingArea(eventId: params.eventId);
  }
}

class GetVotingAreaParams extends Equatable {
  const GetVotingAreaParams({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}
