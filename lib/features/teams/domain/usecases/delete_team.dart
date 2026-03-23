import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class DeleteTeamParams extends Equatable {
  const DeleteTeamParams({required this.teamId});

  final String teamId;

  @override
  List<Object> get props => [teamId];
}

class DeleteTeam extends UseCase<void, DeleteTeamParams> {
  DeleteTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteTeamParams params) {
    return repository.deleteTeam(params.teamId);
  }
}
