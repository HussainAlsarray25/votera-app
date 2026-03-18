import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';

/// Contract for all team-related data operations.
abstract class TeamRepository {
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    String? description,
  });

  Future<Either<Failure, TeamEntity>> getTeam(String teamId);

  Future<Either<Failure, TeamEntity>> getMyTeam();

  Future<Either<Failure, TeamEntity>> updateTeam({
    required String teamId,
    String? name,
    String? description,
  });

  Future<Either<Failure, void>> deleteTeam(String teamId);

  Future<Either<Failure, InvitationEntity>> inviteMember({
    required String teamId,
    required String inviteeId,
  });

  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations();

  Future<Either<Failure, void>> respondToInvitation({
    required String invitationId,
    required bool accept,
  });

  Future<Either<Failure, void>> leaveTeam();

  Future<Either<Failure, void>> removeMember({
    required String teamId,
    required String memberId,
  });

  Future<Either<Failure, void>> transferLeadership({
    required String teamId,
    required String newLeaderId,
  });
}
