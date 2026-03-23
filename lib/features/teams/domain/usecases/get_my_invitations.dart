import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class GetMyInvitations extends UseCase<List<InvitationEntity>, NoParams> {
  GetMyInvitations(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, List<InvitationEntity>>> call(NoParams params) {
    return repository.getMyInvitations();
  }
}
