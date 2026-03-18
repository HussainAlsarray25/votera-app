import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class GetTeamParams extends Equatable {
  const GetTeamParams({required this.teamId});

  final String teamId;

  @override
  List<Object> get props => [teamId];
}

class GetTeam extends UseCase<TeamEntity, GetTeamParams> {
  GetTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, TeamEntity>> call(GetTeamParams params) {
    return repository.getTeam(params.teamId);
  }
}
