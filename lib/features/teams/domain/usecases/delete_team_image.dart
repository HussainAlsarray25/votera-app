import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class DeleteTeamImageParams extends Equatable {
  const DeleteTeamImageParams({required this.teamId});

  final String teamId;

  @override
  List<Object> get props => [teamId];
}

class DeleteTeamImage extends UseCase<void, DeleteTeamImageParams> {
  DeleteTeamImage(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteTeamImageParams params) {
    return repository.deleteTeamImage(teamId: params.teamId);
  }
}
