import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class CreateTeamParams extends Equatable {
  const CreateTeamParams({required this.name, this.description});

  final String name;
  final String? description;

  @override
  List<Object?> get props => [name, description];
}

class CreateTeam extends UseCase<TeamEntity, CreateTeamParams> {
  CreateTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, TeamEntity>> call(CreateTeamParams params) {
    return repository.createTeam(
      name: params.name,
      description: params.description,
    );
  }
}
