import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/rankings/data/datasources/remote/leaderboard_endpoints.dart';
import 'package:votera/features/rankings/data/models/leaderboard_model.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_track.dart';

abstract class LeaderboardRemoteDataSource {
  /// Calls GET /v1/events/{event_id}/leaderboard.
  /// Accepts an optional [track] filter (all | community | supervisor).
  Future<LeaderboardModel> getLeaderboard(
    String eventId, {
    LeaderboardTrack track = LeaderboardTrack.all,
  });

  /// Calls GET /v1/events/{event_id}/leaderboard/final.
  Future<LeaderboardModel> getFinalResults(String eventId);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<LeaderboardModel> getLeaderboard(
    String eventId, {
    LeaderboardTrack track = LeaderboardTrack.all,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      LeaderboardEndpoints.leaderboard(eventId),
      queryParameters: {'track': track.toQueryValue()},
    );

    final body = response.data ?? {};
    // The API wraps the payload in { "success": true, "data": { ... } }.
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return LeaderboardModel.fromJson(data);
  }

  @override
  Future<LeaderboardModel> getFinalResults(String eventId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      LeaderboardEndpoints.finalResults(eventId),
    );

    final body = response.data ?? {};
    // The API wraps the payload in { "success": true, "data": { ... } }.
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return LeaderboardModel.fromJson(data);
  }
}
