import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class ListTeamsParams extends Equatable {
  const ListTeamsParams({
    this.name,
    this.teamHandle,
    this.teamId,
    this.userId,
    this.userHandle,
    this.userName,
  });

  final String? name;
  final String? teamHandle;
  final String? teamId;
  final String? userId;
  final String? userHandle;
  final String? userName;

  bool get isEmpty =>
      name == null &&
      teamHandle == null &&
      teamId == null &&
      userId == null &&
      userHandle == null &&
      userName == null;

  @override
  List<Object?> get props =>
      [name, teamHandle, teamId, userId, userHandle, userName];
}

class ListTeams extends UseCase<List<TeamEntity>, ListTeamsParams> {
  ListTeams(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, List<TeamEntity>>> call(ListTeamsParams params) {
    return repository.listTeams(
      name: params.name,
      teamHandle: params.teamHandle,
      teamId: params.teamId,
      userId: params.userId,
      userHandle: params.userHandle,
      userName: params.userName,
    );
  }
}
