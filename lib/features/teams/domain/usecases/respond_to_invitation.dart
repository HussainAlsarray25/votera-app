import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class RespondToInvitationParams extends Equatable {
  const RespondToInvitationParams({
    required this.invitationId,
    required this.accept,
  });

  final String invitationId;
  final bool accept;

  @override
  List<Object> get props => [invitationId, accept];
}

class RespondToInvitation extends UseCase<void, RespondToInvitationParams> {
  RespondToInvitation(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(RespondToInvitationParams params) {
    return repository.respondToInvitation(
      invitationId: params.invitationId,
      accept: params.accept,
    );
  }
}
