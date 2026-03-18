/// Centralized endpoint paths for the leaderboard/rankings feature.
/// All paths are relative (no leading slash, no version prefix).
class LeaderboardEndpoints {
  const LeaderboardEndpoints._();

  static String leaderboard(String eventId) =>
      'events/$eventId/leaderboard';

  static String finalResults(String eventId) =>
      'events/$eventId/leaderboard/final';
}
