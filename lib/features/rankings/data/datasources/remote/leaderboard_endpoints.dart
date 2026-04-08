/// Centralized endpoint paths for the rankings feature.
/// All paths are relative (no leading slash, no version prefix).
class LeaderboardEndpoints {
  const LeaderboardEndpoints._();

  static String votingResults(String eventId) =>
      'events/$eventId/votes/results';
}
