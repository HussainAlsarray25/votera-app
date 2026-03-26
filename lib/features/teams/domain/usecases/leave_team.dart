import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class LeaveTeam extends UseCase<void, LeaveTeamParams> {
  LeaveTeam(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(LeaveTeamParams params) {
    return repository.leaveTeam(params.teamId);
  }
}

class LeaveTeamParams extends Equatable {
  const LeaveTeamParams({required this.teamId});

  final String teamId;

  @override
  List<Object> get props => [teamId];
}
