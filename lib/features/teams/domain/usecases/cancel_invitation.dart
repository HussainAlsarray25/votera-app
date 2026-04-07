import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class CancelInvitationParams extends Equatable {
  const CancelInvitationParams({
    required this.teamId,
    required this.invitationId,
  });

  final String teamId;
  final String invitationId;

  @override
  List<Object> get props => [teamId, invitationId];
}

class CancelInvitation extends UseCase<void, CancelInvitationParams> {
  CancelInvitation(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(CancelInvitationParams params) {
    return repository.cancelInvitation(
      teamId: params.teamId,
      invitationId: params.invitationId,
    );
  }
}
