import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/ratings/domain/entities/rating_entity.dart';
import 'package:votera/features/ratings/domain/entities/rating_summary_entity.dart';

abstract class RatingRepository {
  /// Creates or updates the authenticated user's rating for a project.
  Future<Either<Failure, RatingEntity>> rateProject({
    required String projectId,
    required int score,
  });

  /// Returns the aggregated rating summary for a project.
  Future<Either<Failure, RatingSummaryEntity>> getRatingSummary(
    String projectId,
  );

  /// Returns the authenticated user's own rating for a project.
  Future<Either<Failure, RatingEntity>> getMyRating(String projectId);
}
