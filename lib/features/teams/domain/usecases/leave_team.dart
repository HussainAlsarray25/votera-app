import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class LeaveTeam extends UseCase<void, NoParams> {
  LeaveTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.leaveTeam();
  }
}
