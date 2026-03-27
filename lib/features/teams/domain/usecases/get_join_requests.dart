import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/join_request_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class GetJoinRequestsParams extends Equatable {
  const GetJoinRequestsParams({required this.teamId});

  final String teamId;

  @override
  List<Object> get props => [teamId];
}

class GetJoinRequests
    extends UseCase<List<JoinRequestEntity>, GetJoinRequestsParams> {
  GetJoinRequests(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, List<JoinRequestEntity>>> call(
    GetJoinRequestsParams params,
  ) {
    return repository.getJoinRequests(teamId: params.teamId);
  }
}
