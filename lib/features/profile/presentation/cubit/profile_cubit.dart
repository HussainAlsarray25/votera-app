import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/usecases/clear_profile_cache.dart';
import 'package:votera/features/profile/domain/usecases/get_cached_profile.dart';
import 'package:votera/features/profile/domain/usecases/get_user_profile.dart';
import 'package:votera/features/profile/domain/usecases/update_user_profile.dart';

part 'profile_state.dart';

/// Manages user profile loading and updates.
///
/// Profile loading is two-phase:
///   Phase 1 — emit cached data immediately if available (no spinner).
///   Phase 2 — fetch fresh data from the backend and update if roles changed.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.getCachedProfile,
    required this.clearProfileCache,
  }) : super(ProfileInitial());

  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;
  final GetCachedProfile getCachedProfile;
  final ClearProfileCache clearProfileCache;

  Future<void> loadProfile() async {
    // Phase 1: serve from cache so the UI reacts instantly on launch.
    final cacheResult = await getCachedProfile(NoParams());
    cacheResult.fold(
      (_) {},
      (cached) {
        if (cached != null) emit(ProfileLoaded(profile: cached));
      },
    );

    // Only show a loading spinner if there was no cached data to display.
    if (state is! ProfileLoaded) emit(ProfileLoading());

    // Phase 2: fetch fresh data from the backend.
    final result = await getUserProfile(NoParams());
    result.fold(
      (failure) {
        // If cached data is already on screen, suppress the error silently.
        // The user sees valid (slightly stale) data rather than an error state.
        if (state is! ProfileLoaded) {
          emit(ProfileError(message: failure.message));
        }
      },
      (fresh) => emit(ProfileLoaded(profile: fresh)),
    );
  }

  /// Clears the profile state and cache. Called on logout so stale data
  /// is not shown to the next user session.
  void reset() {
    // Fire-and-forget — the result does not affect the reset flow.
    clearProfileCache(NoParams());
    emit(ProfileInitial());
  }

  /// Clears the cache and fetches fresh profile data from the backend.
  /// Use this after a role change (e.g. account verification) so the stale
  /// cached role is not served in the two-phase load.
  Future<void> forceRefresh() async {
    await clearProfileCache(NoParams());
    await loadProfile();
  }

  Future<void> updateProfile({String? fullName}) async {
    emit(ProfileLoading());
    final result = await updateUserProfile(
      UpdateProfileParams(fullName: fullName),
    );
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
