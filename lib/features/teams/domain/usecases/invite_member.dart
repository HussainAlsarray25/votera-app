import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class InviteMemberParams extends Equatable {
  const InviteMemberParams({
    required this.teamId,
    required this.inviteeHandle,
    this.message,
  });

  final String teamId;
  final String inviteeHandle;

  // Optional personal message included in the invitation (max 500 chars).
  final String? message;

  @override
  List<Object?> get props => [teamId, inviteeHandle, message];
}

class InviteMember extends UseCase<InvitationEntity, InviteMemberParams> {
  InviteMember(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, InvitationEntity>> call(InviteMemberParams params) {
    return repository.inviteMember(
      teamId: params.teamId,
      inviteeHandle: params.inviteeHandle,
      message: params.message,
    );
  }
}
