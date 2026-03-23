import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/voting/data/datasources/remote/voting_endpoints.dart';

abstract class VotingRemoteDataSource {
  // Casts a vote for a project in an event.
  Future<Map<String, dynamic>> castVote({
    required String eventId,
    required String projectId,
  });

  // Retrieves all votes cast by the current user for a given event.
  Future<List<Map<String, dynamic>>> getMyVotes({required String eventId});

  // Retrieves the aggregated vote tally for all projects in an event.
  Future<Map<String, dynamic>> getVoteTally({required String eventId});

  // Deletes a previously cast vote by its ID.
  Future<void> retractVote({
    required String eventId,
    required String voteId,
  });

  // Retrieves all votes for a given event.
  Future<List<Map<String, dynamic>>> getEventVotes({required String eventId});

  // Retrieves the voting area polygon for a given event.
  Future<Map<String, dynamic>> getVotingArea({required String eventId});
}

class VotingRemoteDataSourceImpl implements VotingRemoteDataSource {
  const VotingRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> castVote({
    required String eventId,
    required String projectId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      VotingEndpoints.votes(eventId),
      data: {'project_id': projectId},
    );
    return response.data!;
  }

  @override
  Future<List<Map<String, dynamic>>> getMyVotes({
    required String eventId,
  }) async {
    final response =
        await apiClient.get<List<dynamic>>(VotingEndpoints.myVotes(eventId));
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> getVoteTally({
    required String eventId,
  }) async {
    final response = await apiClient
        .get<Map<String, dynamic>>(VotingEndpoints.voteTally(eventId));
    return response.data!;
  }

  @override
  Future<void> retractVote({
    required String eventId,
    required String voteId,
  }) async {
    await apiClient.delete<void>(VotingEndpoints.voteById(eventId, voteId));
  }

  @override
  Future<List<Map<String, dynamic>>> getEventVotes({
    required String eventId,
  }) async {
    final response =
        await apiClient.get<List<dynamic>>(VotingEndpoints.votes(eventId));
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> getVotingArea({
    required String eventId,
  }) async {
    final response = await apiClient
        .get<Map<String, dynamic>>(VotingEndpoints.votingArea(eventId));
    return response.data!;
  }
}
