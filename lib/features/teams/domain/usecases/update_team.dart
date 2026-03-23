import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class UpdateTeamParams extends Equatable {
  const UpdateTeamParams({required this.teamId, this.name, this.description});

  final String teamId;
  final String? name;
  final String? description;

  @override
  List<Object?> get props => [teamId, name, description];
}

class UpdateTeam extends UseCase<TeamEntity, UpdateTeamParams> {
  UpdateTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, TeamEntity>> call(UpdateTeamParams params) {
    return repository.updateTeam(
      teamId: params.teamId,
      name: params.name,
      description: params.description,
    );
  }
}
