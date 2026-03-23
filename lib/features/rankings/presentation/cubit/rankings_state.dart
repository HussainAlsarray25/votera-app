part of 'rankings_cubit.dart';

abstract class RankingsState extends Equatable {
  const RankingsState();

  @override
  List<Object?> get props => [];
}

class RankingsInitial extends RankingsState {
  const RankingsInitial();
}

class RankingsLoading extends RankingsState {
  const RankingsLoading();
}

class RankingsLoaded extends RankingsState {
  const RankingsLoaded({required this.leaderboard});

  final LeaderboardEntity leaderboard;

  @override
  List<Object?> get props => [leaderboard];
}

class RankingsError extends RankingsState {
  const RankingsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
