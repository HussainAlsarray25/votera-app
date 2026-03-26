/// Centralized endpoint paths for the participant forms feature.
/// All paths are relative (no leading slash, no version prefix).
class FormsEndpoints {
  const FormsEndpoints._();

  static const String requestEmailOtp  = 'forms/participants/email';
  static const String verifyEmailOtp   = 'forms/participants/email/verify';
  static const String uidRequests      = 'forms/participants/uid';
  static const String uidUploadUrl     = 'forms/participants/uid/upload-url';

  static const String requestSupervisorEmailOtp = 'forms/supervisors/email';
  static const String verifySupervisorEmailOtp  = 'forms/supervisors/email/verify';
}
