import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/rankings/data/datasources/remote/leaderboard_endpoints.dart';
import 'package:votera/features/rankings/data/models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  /// Calls GET /v1/events/{event_id}/leaderboard.
  Future<LeaderboardModel> getLeaderboard(String eventId);

  /// Calls GET /v1/events/{event_id}/leaderboard/final.
  Future<LeaderboardModel> getFinalResults(String eventId);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<LeaderboardModel> getLeaderboard(String eventId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      LeaderboardEndpoints.leaderboard(eventId),
    );

    final body = response.data ?? {};
    return LeaderboardModel.fromJson(body);
  }

  @override
  Future<LeaderboardModel> getFinalResults(String eventId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      LeaderboardEndpoints.finalResults(eventId),
    );

    final body = response.data ?? {};
    return LeaderboardModel.fromJson(body);
  }
}
