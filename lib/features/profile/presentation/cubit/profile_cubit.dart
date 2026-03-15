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

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    emit(ProfileLoading());
    final result = await updateUserProfile(
      UpdateProfileParams(
        name: name,
        email: email,
        phone: phone,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
