import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/teams/data/datasources/remote/team_remote_data_source.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/features/teams/domain/entities/join_request_entity.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  const TeamRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final TeamRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, TeamEntity>> createTeam({
    required String name,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.createTeam(name: name, description: description);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> getTeam(String teamId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getTeam(teamId);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getMyTeams() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getMyTeams();
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> updateTeam({
    required String teamId,
    String? name,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.updateTeam(
        teamId: teamId,
        name: name,
        description: description,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeam(String teamId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.deleteTeam(teamId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, InvitationEntity>> inviteMember({
    required String teamId,
    required String inviteeHandle,
    String? message,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.inviteMember(
        teamId: teamId,
        inviteeHandle: inviteeHandle,
        message: message,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getMyInvitations();
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.respondToInvitation(invitationId: invitationId, accept: accept);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(String teamId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.leaveTeam(teamId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.removeMember(teamId: teamId, memberId: memberId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> transferLeadership({
    required String teamId,
    required String newLeaderId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.transferLeadership(teamId: teamId, newLeaderId: newLeaderId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<TeamEntity>>> listTeams({
    String? name,
    String? teamHandle,
    String? teamId,
    String? userId,
    String? userHandle,
    String? userName,
    int? page,
    int? size,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.listTeams(
        name: name,
        teamHandle: teamHandle,
        teamId: teamId,
        userId: userId,
        userHandle: userHandle,
        userName: userName,
        page: page,
        size: size,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> cancelInvitation({
    required String teamId,
    required String invitationId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.cancelInvitation(teamId: teamId, invitationId: invitationId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  // -- Join Requests -----------------------------------------------------------

  @override
  Future<Either<Failure, JoinRequestEntity>> sendJoinRequest({
    required String teamId,
    String? message,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.sendJoinRequest(teamId: teamId, message: message);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestEntity>>> getJoinRequests({
    required String teamId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getJoinRequests(teamId: teamId);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> respondJoinRequest({
    required String teamId,
    required String requestId,
    required bool approve,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.respondJoinRequest(
        teamId: teamId,
        requestId: requestId,
        approve: approve,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  // -- Team Image --------------------------------------------------------------

  @override
  Future<Either<Failure, void>> uploadTeamImage({
    required String teamId,
    required String fileName,
    List<int>? bytes,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    if (bytes == null) {
      return const Left(
        ServerFailure(message: 'No file data provided for upload'),
      );
    }
    try {
      await remote.uploadTeamImage(
        teamId: teamId,
        bytes: bytes,
        contentType: _contentTypeFromName(fileName),
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  /// Derive a MIME content type from the file extension.
  String _contentTypeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  @override
  Future<Either<Failure, void>> deleteTeamImage({required String teamId}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.deleteTeamImage(teamId: teamId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}
