/// Centralized endpoint paths for the voting feature.
/// All paths are relative (no leading slash, no version prefix).
class VotingEndpoints {
  const VotingEndpoints._();

  static String votes(String eventId) => 'events/$eventId/votes';

  static String myVotes(String eventId) => 'events/$eventId/votes/my';

  static String voteTally(String eventId) => 'events/$eventId/votes/tally';

  static String voteById(String eventId, String voteId) =>
      'events/$eventId/votes/$voteId';

}
