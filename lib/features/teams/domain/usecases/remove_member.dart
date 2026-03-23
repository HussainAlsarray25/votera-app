import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class RemoveMemberParams extends Equatable {
  const RemoveMemberParams({required this.teamId, required this.memberId});

  final String teamId;
  final String memberId;

  @override
  List<Object> get props => [teamId, memberId];
}

class RemoveMember extends UseCase<void, RemoveMemberParams> {
  RemoveMember(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(RemoveMemberParams params) {
    return repository.removeMember(
      teamId: params.teamId,
      memberId: params.memberId,
    );
  }
}
