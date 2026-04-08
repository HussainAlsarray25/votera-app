import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/rankings/data/datasources/remote/leaderboard_endpoints.dart';
import 'package:votera/features/rankings/data/models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  /// Calls GET /v1/events/{event_id}/votes/results with no track filter,
  /// returning the weighted overall result.
  Future<LeaderboardModel> getVotingResults(String eventId);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<LeaderboardModel> getVotingResults(String eventId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      LeaderboardEndpoints.votingResults(eventId),
    );

    final body = response.data ?? {};
    // The API wraps the payload in { "success": true, "data": { ... } }.
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return LeaderboardModel.fromJson(data);
  }
}
