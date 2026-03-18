import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';
import 'package:votera/features/participants/domain/usecases/get_my_participation.dart';
import 'package:votera/features/participants/domain/usecases/get_participants.dart';
import 'package:votera/features/participants/domain/usecases/register_for_event.dart';

part 'participants_state.dart';

/// Manages all application-related interactions for an event screen.
/// Each public method maps to one use case, keeping responsibilities focused.
class ApplicationsCubit extends Cubit<ApplicationsState> {
  ApplicationsCubit({
    required this.getApplications,
    required this.submitApplication,
    required this.getMyApplication,
  }) : super(const ApplicationsInitial());

  final GetApplications getApplications;
  final SubmitApplication submitApplication;
  final GetMyApplication getMyApplication;

  /// Loads the paginated application list for [eventId].
  Future<void> loadApplications({
    required String eventId,
    int page = 1,
    int size = 20,
  }) async {
    emit(const ApplicationsLoading());
    final result = await getApplications(
      GetApplicationsParams(eventId: eventId, page: page, size: size),
    );
    result.fold(
      (failure) => emit(ApplicationsError(message: failure.message)),
      (data) => emit(ApplicationsLoaded(applications: data)),
    );
  }

  /// Submits an application for [teamId] to [eventId].
  Future<void> submit({
    required String eventId,
    required String teamId,
  }) async {
    emit(const ApplicationsLoading());
    final result = await submitApplication(
      SubmitApplicationParams(eventId: eventId, teamId: teamId),
    );
    result.fold(
      (failure) => emit(ApplicationsError(message: failure.message)),
      (application) => emit(ApplicationSubmitted(application: application)),
    );
  }

  /// Loads the authenticated user's team application for [eventId].
  Future<void> loadMyApplication({
    required String eventId,
    required String teamId,
  }) async {
    emit(const ApplicationsLoading());
    final result = await getMyApplication(
      GetMyApplicationParams(eventId: eventId, teamId: teamId),
    );
    result.fold(
      (failure) => emit(ApplicationsError(message: failure.message)),
      (application) => emit(MyApplicationLoaded(application: application)),
    );
  }
}
