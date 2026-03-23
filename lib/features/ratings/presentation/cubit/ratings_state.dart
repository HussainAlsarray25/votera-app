part of 'ratings_cubit.dart';

abstract class RatingsState extends Equatable {
  const RatingsState();

  @override
  List<Object?> get props => [];
}

class RatingsInitial extends RatingsState {
  const RatingsInitial();
}

class RatingsLoading extends RatingsState {
  const RatingsLoading();
}

class RatingLoaded extends RatingsState {
  const RatingLoaded({required this.rating});

  final RatingEntity rating;

  @override
  List<Object?> get props => [rating];
}

class RatingSummaryLoaded extends RatingsState {
  const RatingSummaryLoaded({required this.summary});

  final RatingSummaryEntity summary;

  @override
  List<Object?> get props => [summary];
}

class RatingsError extends RatingsState {
  const RatingsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
