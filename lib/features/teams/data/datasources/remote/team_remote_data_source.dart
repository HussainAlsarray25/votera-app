import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/teams/data/datasources/remote/team_endpoints.dart';
import 'package:votera/features/teams/data/models/invitation_model.dart';
import 'package:votera/features/teams/data/models/join_request_model.dart';
import 'package:votera/features/teams/data/models/team_model.dart';

abstract class TeamRemoteDataSource {
  Future<TeamModel> createTeam({required String name, String? description});
  Future<TeamModel> getTeam(String teamId);
  Future<List<TeamModel>> getMyTeams();
  Future<TeamModel> updateTeam({required String teamId, String? name, String? description});
  Future<void> deleteTeam(String teamId);

  /// Invite a user by handle. [message] is optional (max 500 chars).
  Future<InvitationModel> inviteMember({
    required String teamId,
    required String inviteeHandle,
    String? message,
  });

  // GET /v1/teams/invitations — returns all pending invitations for the current user.
  Future<List<InvitationModel>> getMyInvitations();
  Future<void> respondToInvitation({required String invitationId, required bool accept});
  Future<void> leaveTeam(String teamId);
  Future<void> removeMember({required String teamId, required String memberId});
  Future<void> transferLeadership({required String teamId, required String newLeaderId});

  /// GET /v1/teams with optional filter params and pagination.
  Future<PaginatedResponse<TeamModel>> listTeams({
    String? name,
    String? teamHandle,
    String? teamId,
    String? userId,
    String? userHandle,
    String? userName,
    int? page,
    int? size,
  });

  /// DELETE /v1/teams/{teamId}/invitations/{invitationId} — leader only.
  Future<void> cancelInvitation({
    required String teamId,
    required String invitationId,
  });

  // -- Join Requests -----------------------------------------------------------

  Future<JoinRequestModel> sendJoinRequest({
    required String teamId,
    String? message,
  });

  Future<List<JoinRequestModel>> getJoinRequests({required String teamId});

  Future<void> respondJoinRequest({
    required String teamId,
    required String requestId,
    required bool approve,
  });

  // -- Team Image --------------------------------------------------------------

  /// POST raw image bytes directly to /v1/teams/:id/image with auth header.
  Future<void> uploadTeamImage({
    required String teamId,
    required List<int> bytes,
    required String contentType,
  });

  Future<void> deleteTeamImage({required String teamId});
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  const TeamRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<TeamModel> createTeam({required String name, String? description}) async {
    final body = <String, dynamic>{'name': name};
    if (description != null) body['description'] = description;
    final response = await apiClient.post<Map<String, dynamic>>(
      TeamEndpoints.teams,
      data: body,
    );
    return TeamModel.fromJson(response.data!);
  }

  @override
  Future<TeamModel> getTeam(String teamId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      TeamEndpoints.teamById(teamId),
    );
    return TeamModel.fromJson(response.data!);
  }

  @override
  Future<List<TeamModel>> getMyTeams() async {
    // GET /teams/my returns an array of teams.
    final response = await apiClient.get<Map<String, dynamic>>(
      TeamEndpoints.myTeam,
    );
    final items = response.data!['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TeamModel> updateTeam({
    required String teamId,
    String? name,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    final response = await apiClient.put<Map<String, dynamic>>(
      TeamEndpoints.teamById(teamId),
      data: body,
    );
    return TeamModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    await apiClient.delete<void>(TeamEndpoints.teamById(teamId));
  }

  @override
  Future<InvitationModel> inviteMember({
    required String teamId,
    required String inviteeHandle,
    String? message,
  }) async {
    final body = <String, dynamic>{'invitee_handle': inviteeHandle};
    if (message != null && message.isNotEmpty) body['message'] = message;
    final response = await apiClient.post<Map<String, dynamic>>(
      TeamEndpoints.teamInvitations(teamId),
      data: body,
    );
    return InvitationModel.fromJson(response.data!);
  }

  @override
  Future<List<InvitationModel>> getMyInvitations() async {
    // The API wraps the list in the standard envelope: {success, data: [...]}.
    final response = await apiClient.get<Map<String, dynamic>>(
      TeamEndpoints.myInvitations,
    );
    final items = response.data!['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    await apiClient.put<void>(
      TeamEndpoints.invitationById(invitationId),
      data: {'accept': accept},
    );
  }

  @override
  Future<void> leaveTeam(String teamId) async {
    await apiClient.post<void>(TeamEndpoints.leaveTeam(teamId));
  }

  @override
  Future<void> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    await apiClient.delete<void>(TeamEndpoints.teamMember(teamId, memberId));
  }

  @override
  Future<void> transferLeadership({
    required String teamId,
    required String newLeaderId,
  }) async {
    await apiClient.post<void>(
      TeamEndpoints.transferLeadership(teamId),
      data: {'new_leader_id': newLeaderId},
    );
  }

  @override
  Future<PaginatedResponse<TeamModel>> listTeams({
    String? name,
    String? teamHandle,
    String? teamId,
    String? userId,
    String? userHandle,
    String? userName,
    int? page,
    int? size,
  }) async {
    final query = <String, dynamic>{};
    if (name != null) query['name'] = name;
    if (teamHandle != null) query['team_handle'] = teamHandle;
    if (teamId != null) query['team_id'] = teamId;
    if (userId != null) query['user_id'] = userId;
    if (userHandle != null) query['user_handle'] = userHandle;
    if (userName != null) query['user_name'] = userName;
    if (page != null) query['page'] = page;
    if (size != null) query['size'] = size;

    final response = await apiClient.get<Map<String, dynamic>>(
      TeamEndpoints.teams,
      queryParameters: query.isEmpty ? null : query,
    );
    return PaginatedResponse.fromJson(
      response.data!,
      TeamModel.fromJson,
    );
  }

  @override
  Future<void> cancelInvitation({
    required String teamId,
    required String invitationId,
  }) async {
    // DELETE /v1/teams/{teamId}/invitations/{invitationId}
    await apiClient.delete<void>(
      TeamEndpoints.cancelInvitation(teamId, invitationId),
    );
  }

  // -- Join Requests -----------------------------------------------------------

  @override
  Future<JoinRequestModel> sendJoinRequest({
    required String teamId,
    String? message,
  }) async {
    final body = <String, dynamic>{};
    if (message != null && message.isNotEmpty) body['message'] = message;
    final response = await apiClient.post<Map<String, dynamic>>(
      TeamEndpoints.joinRequests(teamId),
      data: body.isEmpty ? null : body,
    );
    return JoinRequestModel.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<JoinRequestModel>> getJoinRequests({
    required String teamId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      TeamEndpoints.joinRequests(teamId),
    );
    final items = response.data!['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => JoinRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> respondJoinRequest({
    required String teamId,
    required String requestId,
    required bool approve,
  }) async {
    await apiClient.put<void>(
      TeamEndpoints.joinRequestById(teamId, requestId),
      data: {'approve': approve},
    );
  }

  // -- Team Image --------------------------------------------------------------

  @override
  Future<void> uploadTeamImage({
    required String teamId,
    required List<int> bytes,
    required String contentType,
  }) async {
    final imageBytes = Uint8List.fromList(bytes);
    
    await apiClient.post<void>(
      TeamEndpoints.teamImage(teamId),
      data: imageBytes,
      options: Options(
        contentType: contentType,
        headers: {
          'Content-Length': imageBytes.length,
        },
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  @override
  Future<void> deleteTeamImage({required String teamId}) async {
    await apiClient.delete<void>(TeamEndpoints.teamImage(teamId));
  }
}
