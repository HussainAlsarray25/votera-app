import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/entities/join_request_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/entities/team_image_upload_url_entity.dart';

/// Contract for all team-related data operations.
abstract class TeamRepository {
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    String? description,
  });

  Future<Either<Failure, TeamEntity>> getTeam(String teamId);

  Future<Either<Failure, List<TeamEntity>>> getMyTeams();

  Future<Either<Failure, TeamEntity>> updateTeam({
    required String teamId,
    String? name,
    String? description,
  });

  Future<Either<Failure, void>> deleteTeam(String teamId);

  /// [message] is optional (max 500 chars) and sent with the invitation.
  Future<Either<Failure, InvitationEntity>> inviteMember({
    required String teamId,
    required String inviteeHandle,
    String? message,
  });

  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations();

  Future<Either<Failure, void>> respondToInvitation({
    required String invitationId,
    required bool accept,
  });

  Future<Either<Failure, void>> leaveTeam(String teamId);

  Future<Either<Failure, void>> removeMember({
    required String teamId,
    required String memberId,
  });

  Future<Either<Failure, void>> transferLeadership({
    required String teamId,
    required String newLeaderId,
  });

  Future<Either<Failure, PaginatedResponse<TeamEntity>>> listTeams({
    String? name,
    String? teamHandle,
    String? teamId,
    String? userId,
    String? userHandle,
    String? userName,
    int? page,
    int? size,
  });

  /// Cancel a pending invitation to a team. Only the team leader can do this.
  Future<Either<Failure, void>> cancelInvitation({
    required String teamId,
    required String invitationId,
  });

  // -- Join Requests -----------------------------------------------------------

  /// Send a request to join a team. [message] is optional (max 500 chars).
  Future<Either<Failure, JoinRequestEntity>> sendJoinRequest({
    required String teamId,
    String? message,
  });

  /// List all pending join requests for a team. Leader only.
  Future<Either<Failure, List<JoinRequestEntity>>> getJoinRequests({
    required String teamId,
  });

  /// Approve or decline a join request. Leader only.
  Future<Either<Failure, void>> respondJoinRequest({
    required String teamId,
    required String requestId,
    required bool approve,
  });

  // -- Team Image --------------------------------------------------------------

  /// Get a presigned S3 URL to upload the team avatar. Leader only.
  Future<Either<Failure, TeamImageUploadUrlEntity>> getTeamImageUploadUrl({
    required String teamId,
    required String fileName,
  });

  /// Delete the team avatar. Leader only.
  Future<Either<Failure, void>> deleteTeamImage({required String teamId});
}
