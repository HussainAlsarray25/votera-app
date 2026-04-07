part of 'forms_cubit.dart';

abstract class FormsState extends Equatable {
  const FormsState();

  @override
  List<Object?> get props => [];
}

class FormsInitial extends FormsState {}

class FormsLoading extends FormsState {}

/// OTP has been sent to the institutional email. The UI should show the OTP input.
class FormsEmailOtpSent extends FormsState {
  const FormsEmailOtpSent({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Email OTP verified — the backend has granted the participant role.
/// The profile should be reloaded to reflect the new role.
class FormsEmailVerified extends FormsState {}

/// UID card requests fetched successfully.
class FormsUidRequestsLoaded extends FormsState {
  const FormsUidRequestsLoaded({required this.requests});

  final List<ParticipantRequest> requests;

  @override
  List<Object?> get props => [requests];
}

/// Document uploaded to MinIO. [publicUrl] should be used in the UID form submission.
/// [fileName] is shown in the UI to confirm the upload.
class FormsDocumentUploaded extends FormsState {
  const FormsDocumentUploaded({
    required this.publicUrl,
    required this.fileName,
  });

  final String publicUrl;
  final String fileName;

  @override
  List<Object?> get props => [publicUrl, fileName];
}

/// UID card request submitted and is pending admin review.
class FormsUidSubmitted extends FormsState {}

/// OTP sent to supervisor email; UI should show OTP input.
class FormsSupEmailOtpSent extends FormsState {
  const FormsSupEmailOtpSent({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Supervisor email verified — supervisor role granted by backend.
class FormsSupervisorEmailVerified extends FormsState {}

class FormsError extends FormsState {
  const FormsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
