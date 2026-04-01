part of 'force_update_cubit.dart';

abstract class ForceUpdateState extends Equatable {
  const ForceUpdateState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any version check has been performed.
class ForceUpdateInitial extends ForceUpdateState {}

/// Version check is in progress — the app renders normally during this time.
class ForceUpdateChecking extends ForceUpdateState {}

/// Check completed and no update is required — normal app flow continues.
class ForceUpdateNotRequired extends ForceUpdateState {}

/// An update is required — the UI must be blocked until the user updates.
class ForceUpdateRequired extends ForceUpdateState {
  const ForceUpdateRequired({
    required this.updateUrl,
    required this.latestVersionName,
    required this.messageEn,
    required this.messageAr,
  });

  final String updateUrl;

  /// Human-readable version name shown in the dialog (e.g. "2.1.0").
  final String latestVersionName;

  /// Server-provided update message in English.
  final String messageEn;

  /// Server-provided update message in Arabic.
  final String messageAr;

  @override
  List<Object?> get props => [updateUrl, latestVersionName, messageEn, messageAr];
}

/// The check failed (network or server error).
///
/// The app proceeds normally rather than blocking the user on a failed check.
/// A version check failure should never prevent a user from using the app.
class ForceUpdateCheckFailed extends ForceUpdateState {
  const ForceUpdateCheckFailed({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
