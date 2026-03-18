import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/teams/data/datasources/remote/team_endpoints.dart';
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
  Future<TeamModel> getMyTeam() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      TeamEndpoints.myTeam,
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
    required String inviteeId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      TeamEndpoints.teamInvitations(teamId),
      data: {'invitee_id': inviteeId},
    );
    return InvitationModel.fromJson(response.data!);
  }

  @override
  Future<List<InvitationModel>> getMyInvitations() async {
    final response = await apiClient.get<List<dynamic>>(
      TeamEndpoints.myInvitations,
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
      TeamEndpoints.invitationById(invitationId),
      data: {'accept': accept},
    );
  }

  @override
  Future<void> leaveTeam() async {
    await apiClient.post<void>(TeamEndpoints.leaveTeam);
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
}
