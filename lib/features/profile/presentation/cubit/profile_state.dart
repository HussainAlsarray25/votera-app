part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Emitted while a profile field update (e.g. name) is in flight.
/// Keeps the last known profile so the UI never goes blank during the save.
class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileAvatarUploading extends ProfileState {
  const ProfileAvatarUploading({required this.profile});

  /// The last known profile — allows the UI to keep showing data while the
  /// upload is in progress.
  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  const ProfileError({required this.message, this.profile});

  final String message;
  // Preserved profile so the UI can keep displaying data after a failed update.
  final UserProfile? profile;

  @override
  List<Object?> get props => [message, profile];
}
