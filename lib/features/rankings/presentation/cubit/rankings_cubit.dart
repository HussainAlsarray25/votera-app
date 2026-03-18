import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';
import 'package:votera/features/rankings/domain/usecases/get_final_results.dart';
import 'package:votera/features/rankings/domain/usecases/get_leaderboard.dart';

part 'rankings_state.dart';

/// Manages fetching and exposing leaderboard data for a given event.
/// Supports both the live leaderboard and the final published results.
class RankingsCubit extends Cubit<RankingsState> {
  RankingsCubit({
    required this.getLeaderboard,
    required this.getFinalResults,
  }) : super(const RankingsInitial());

  final GetLeaderboard getLeaderboard;
  final GetFinalResults getFinalResults;

  /// Loads the live leaderboard for the given [eventId].
  Future<void> loadLeaderboard(String eventId) async {
    emit(const RankingsLoading());
    final result = await getLeaderboard(GetLeaderboardParams(eventId: eventId));
    result.fold(
      (failure) => emit(RankingsError(message: failure.message)),
      (leaderboard) => emit(RankingsLoaded(leaderboard: leaderboard)),
    );
  }

  /// Loads the final published results for the given [eventId].
  Future<void> loadFinalResults(String eventId) async {
    emit(const RankingsLoading());
    final result = await getFinalResults(
      GetFinalResultsParams(eventId: eventId),
    );
    result.fold(
      (failure) => emit(RankingsError(message: failure.message)),
      (leaderboard) => emit(RankingsLoaded(leaderboard: leaderboard)),
    );
  }
}
