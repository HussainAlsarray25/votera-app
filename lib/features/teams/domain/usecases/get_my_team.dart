import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class GetMyTeam extends UseCase<List<TeamEntity>, NoParams> {
  GetMyTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, List<TeamEntity>>> call(NoParams params) {
    return repository.getMyTeams();
  }
}
