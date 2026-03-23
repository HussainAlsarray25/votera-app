import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/domain/services/location_service.dart';
import 'package:votera/core/utils/geo_utils.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/entities/voting_area_entity.dart';
import 'package:votera/features/voting/domain/usecases/cast_vote.dart';
import 'package:votera/features/voting/domain/usecases/get_event_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_my_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_vote_tally.dart';
import 'package:votera/features/voting/domain/usecases/get_voting_area.dart';
import 'package:votera/features/voting/domain/usecases/retract_vote.dart';

part 'voting_state.dart';

/// Manages all voting actions for an event: casting, fetching, tallying, and
/// retracting votes. Includes geofence verification before casting.
class VotingCubit extends Cubit<VotingState> {
  VotingCubit({
    required this.castVote,
    required this.getMyVotes,
    required this.getVoteTally,
    required this.retractVote,
    required this.getEventVotes,
    required this.getVotingArea,
    required this.locationService,
  }) : super(const VotingInitial());

  final CastVote castVote;
  final GetMyVotes getMyVotes;
  final GetVoteTally getVoteTally;
  final RetractVote retractVote;
  final GetEventVotes getEventVotes;
  final GetVotingArea getVotingArea;
  final LocationService locationService;

  VotingAreaEntity? _cachedVotingArea;

  /// Pre-fetches the voting area polygon for [eventId] on page load.
  /// The result is cached so that submitVote does not need a second fetch.
  Future<void> prefetchVotingArea({required String eventId}) async {
    final result = await getVotingArea(
      GetVotingAreaParams(eventId: eventId),
    );
    result.fold(
      // Prefetch failure is non-critical; will retry on vote tap.
      (_) {},
      (area) {
        _cachedVotingArea = area;
        emit(VotingAreaLoaded(votingArea: area));
      },
    );
  }

  Future<void> loadMyVotes({required String eventId}) async {
    emit(const VotingLoading());
    final result = await getMyVotes(GetMyVotesParams(eventId: eventId));
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (votes) => emit(VotesLoaded(votes: votes)),
    );
  }

  Future<void> submitVote({
    required String eventId,
    required String projectId,
  }) async {
    // 1. Check GPS location.
    emit(const VotingLocationCheck());

    final locationResult = await locationService.getCurrentPosition();

    final position = locationResult.fold<GeoPosition?>(
      (failure) {
        emit(
          LocationUnavailable(
            message: failure.message,
            isDeniedForever: failure.isDeniedForever,
          ),
        );
        return null;
      },
      (pos) => pos,
    );

    if (position == null) return;

    // 2. Get voting area -- use cache or fetch on demand.
    var votingArea = _cachedVotingArea;
    if (votingArea == null) {
      final areaResult = await getVotingArea(
        GetVotingAreaParams(eventId: eventId),
      );
      final fetched = areaResult.fold<VotingAreaEntity?>(
        (failure) {
          emit(VotingError(message: failure.message));
          return null;
        },
        (area) {
          _cachedVotingArea = area;
          return area;
        },
      );
      if (fetched == null) return;
      votingArea = fetched;
    }

    // 3. Run geofence check.
    if (!isPointInPolygon(position, votingArea.polygon)) {
      emit(
        const OutsideVotingArea(
          message: 'You must be inside the voting area to cast your vote.',
        ),
      );
      return;
    }

    // 4. Cast the vote.
    emit(const VotingLoading());
    final result = await castVote(
      CastVoteParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (vote) => emit(VoteCast(vote: vote)),
    );
  }

  Future<void> loadTally({required String eventId}) async {
    emit(const VotingLoading());
    final result = await getVoteTally(GetVoteTallyParams(eventId: eventId));
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (tally) => emit(TallyLoaded(tally: tally)),
    );
  }

  Future<void> removeVote({
    required String eventId,
    required String voteId,
  }) async {
    emit(const VotingLoading());
    final result = await retractVote(
      RetractVoteParams(eventId: eventId, voteId: voteId),
    );
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (_) => emit(const VoteRetracted()),
    );
  }

  Future<void> loadEventVotes({required String eventId}) async {
    emit(const VotingLoading());
    final result = await getEventVotes(
      GetEventVotesParams(eventId: eventId),
    );
    result.fold(
      (failure) => emit(VotingError(message: failure.message)),
      (votes) => emit(VotesLoaded(votes: votes)),
    );
  }
}
