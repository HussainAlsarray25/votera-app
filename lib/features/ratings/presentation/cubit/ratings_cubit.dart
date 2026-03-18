import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/ratings/domain/entities/rating_entity.dart';
import 'package:votera/features/ratings/domain/entities/rating_summary_entity.dart';
import 'package:votera/features/ratings/domain/usecases/get_my_rating.dart';
import 'package:votera/features/ratings/domain/usecases/get_rating_summary.dart';
import 'package:votera/features/ratings/domain/usecases/rate_project.dart';

part 'ratings_state.dart';

/// Manages project rating state transitions.
class RatingsCubit extends Cubit<RatingsState> {
  RatingsCubit({
    required this.rateProject,
    required this.getRatingSummary,
    required this.getMyRating,
  }) : super(const RatingsInitial());

  final RateProject rateProject;
  final GetRatingSummary getRatingSummary;
  final GetMyRating getMyRating;

  Future<void> rate({required String projectId, required int score}) async {
    emit(const RatingsLoading());
    final result = await rateProject(
      RateProjectParams(projectId: projectId, score: score),
    );
    result.fold(
      (failure) => emit(RatingsError(message: failure.message)),
      (rating) => emit(RatingLoaded(rating: rating)),
    );
  }

  Future<void> loadSummary(String projectId) async {
    emit(const RatingsLoading());
    final result = await getRatingSummary(
      GetRatingSummaryParams(projectId: projectId),
    );
    result.fold(
      (failure) => emit(RatingsError(message: failure.message)),
      (summary) => emit(RatingSummaryLoaded(summary: summary)),
    );
  }

  Future<void> loadMyRating(String projectId) async {
    emit(const RatingsLoading());
    final result = await getMyRating(
      GetMyRatingParams(projectId: projectId),
    );
    result.fold(
      (failure) => emit(RatingsError(message: failure.message)),
      (rating) => emit(RatingLoaded(rating: rating)),
    );
  }
}
