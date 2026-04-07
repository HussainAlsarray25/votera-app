import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';
import 'package:votera/features/rankings/domain/usecases/get_leaderboard.dart';

part 'rankings_state.dart';

/// Manages fetching and exposing voting results for a given event.
class RankingsCubit extends Cubit<RankingsState> {
  RankingsCubit({required this.getVotingResults}) : super(const RankingsInitial());

  final GetVotingResults getVotingResults;

  /// Loads the weighted overall voting results for [eventId].
  Future<void> loadVotingResults(String eventId) async {
    emit(const RankingsLoading());
    final result = await getVotingResults(
      GetVotingResultsParams(eventId: eventId),
    );
    result.fold(
      (failure) => emit(RankingsError(message: failure.message)),
      (leaderboard) => emit(RankingsLoaded(leaderboard: leaderboard)),
    );
  }
}
