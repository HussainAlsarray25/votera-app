import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/usecases/get_user_profile.dart';
import 'package:votera/features/profile/domain/usecases/update_user_profile.dart';

part 'profile_state.dart';

/// Manages user profile loading and updates.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(ProfileInitial());

  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await getUserProfile(NoParams());
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  /// Resets the profile state to initial. Called on logout
  /// so stale data is not shown to the next user.
  void reset() => emit(ProfileInitial());

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
