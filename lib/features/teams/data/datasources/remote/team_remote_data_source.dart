import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/teams/data/models/invitation_model.dart';
import 'package:votera/features/teams/data/models/team_model.dart';

abstract class TeamRemoteDataSource {
  Future<TeamModel> createTeam({required String name, String? description});
  Future<TeamModel> getTeam(String teamId);
  Future<TeamModel> getMyTeam();
  Future<TeamModel> updateTeam({required String teamId, String? name, String? description});
  Future<void> deleteTeam(String teamId);
  Future<InvitationModel> inviteMember({required String teamId, required String inviteeId});
  Future<List<InvitationModel>> getMyInvitations();
  Future<void> respondToInvitation({required String invitationId, required bool accept});
  Future<void> leaveTeam();
  Future<void> removeMember({required String teamId, required String memberId});
  Future<void> transferLeadership({required String teamId, required String newLeaderId});
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  const TeamRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<TeamModel> createTeam({required String name, String? description}) async {
    final body = <String, dynamic>{'name': name};
    if (description != null) body['description'] = description;
    final response = await apiClient.post<Map<String, dynamic>>(
      '/v1/teams',
      data: body,
    );
    return TeamModel.fromJson(response.data!);
  }

  @override
  Future<TeamModel> getTeam(String teamId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/teams/$teamId',
    );
    return TeamModel.fromJson(response.data!);
  }

  @override
  Future<TeamModel> getMyTeam() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/teams/my',
    );
    return TeamModel.fromJson(response.data!);
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
      '/v1/teams/$teamId',
      data: body,
    );
    return TeamModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    await apiClient.delete<void>('/v1/teams/$teamId');
  }

  @override
  Future<InvitationModel> inviteMember({
    required String teamId,
    required String inviteeId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/v1/teams/$teamId/invitations',
      data: {'invitee_id': inviteeId},
    );
    return InvitationModel.fromJson(response.data!);
  }

  @override
  Future<List<InvitationModel>> getMyInvitations() async {
    final response = await apiClient.get<List<dynamic>>(
      '/v1/teams/invitations',
    );
    return (response.data ?? [])
        .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    await apiClient.put<void>(
      '/v1/teams/invitations/$invitationId',
      data: {'accept': accept},
    );
  }

  @override
  Future<void> leaveTeam() async {
    await apiClient.post<void>('/v1/teams/my/leave');
  }

  @override
  Future<void> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    await apiClient.delete<void>('/v1/teams/$teamId/members/$memberId');
  }

  @override
  Future<void> transferLeadership({
    required String teamId,
    required String newLeaderId,
  }) async {
    await apiClient.post<void>(
      '/v1/teams/$teamId/transfer-leadership',
      data: {'new_leader_id': newLeaderId},
    );
  }
}
