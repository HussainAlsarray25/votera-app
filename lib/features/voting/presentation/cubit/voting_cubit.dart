import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/domain/services/location_service.dart';
import 'package:votera/core/utils/geo_utils.dart';
import 'package:votera/features/events/domain/usecases/get_event_by_id.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/usecases/cast_vote.dart';
import 'package:votera/features/voting/domain/usecases/get_event_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_my_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_vote_tally.dart';
import 'package:votera/features/voting/domain/usecases/retract_vote.dart';

part 'voting_state.dart';

/// Manages all voting actions for an event: casting, fetching, tallying, and
/// retracting votes. Includes geofence verification before casting when the
/// event has a configured location (latitude/longitude).
class VotingCubit extends Cubit<VotingState> {
  VotingCubit({
    required this.castVote,
    required this.getMyVotes,
    required this.getVoteTally,
    required this.retractVote,
    required this.getEventVotes,
    required this.getEventById,
    required this.locationService,
  }) : super(const VotingInitial());

  final CastVote castVote;
  final GetMyVotes getMyVotes;
  final GetVoteTally getVoteTally;
  final RetractVote retractVote;
  final GetEventVotes getEventVotes;
  final GetEventById getEventById;
  final LocationService locationService;

  // The event's venue coordinates, loaded during init.
  // Null means no geo-fence restriction is applied for this event.
  GeoPosition? _eventLocation;

  /// Loads the event by [eventId] and stores its location for geo-fencing.
  /// Called on page load so that submitVote does not need a separate fetch.
  /// Failure here is non-critical — voting will proceed without geo-fencing.
  Future<void> loadEventLocation({required String eventId}) async {
    final result = await getEventById(GetEventByIdParams(id: eventId));
    result.fold(
      (_) {},
      (event) {
        if (event.latitude != null && event.longitude != null) {
          _eventLocation = GeoPosition(
            latitude: event.latitude!,
            longitude: event.longitude!,
          );
        }
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
    // Only run a geo-fence check when the event has a configured location.
    if (_eventLocation != null) {
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

      if (!isWithinRadius(position, _eventLocation)) {
        emit(
          const OutsideVotingArea(
            message: 'You must be inside the voting area to cast your vote.',
          ),
        );
        return;
      }
    }

    // Cast the vote.
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
