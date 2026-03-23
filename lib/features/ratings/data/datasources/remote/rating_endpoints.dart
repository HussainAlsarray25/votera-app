/// Centralized endpoint paths for the ratings feature.
/// All paths are relative (no leading slash, no version prefix).
class RatingEndpoints {
  const RatingEndpoints._();

  static String rating(String projectId) => 'projects/$projectId/rating';

  static String myRating(String projectId) => 'projects/$projectId/rating/my';
}
