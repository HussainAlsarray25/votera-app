/// Centralized endpoint paths for the participants/applications feature.
/// All paths are relative (no leading slash, no version prefix).
class ParticipantEndpoints {
  const ParticipantEndpoints._();

  static String applications(String eventId) =>
      'events/$eventId/applications';

  static String myApplication(String eventId) =>
      'events/$eventId/applications/my';
}
