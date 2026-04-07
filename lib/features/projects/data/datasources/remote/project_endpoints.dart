/// Centralized endpoint paths for the projects feature.
/// All paths are relative (no leading slash, no version prefix).
class ProjectEndpoints {
  const ProjectEndpoints._();

  static String projects(String eventId) => 'events/$eventId/projects';

  static String projectById(String eventId, String projectId) =>
      'events/$eventId/projects/$projectId';

  static String scan(String token) => 'scan/$token';

  static String projectCategory(
    String eventId,
    String projectId,
    String categoryId,
  ) =>
      'events/$eventId/projects/$projectId/categories/$categoryId';

  static String submitProject(String eventId, String projectId) =>
      'events/$eventId/projects/$projectId/submit';

  static String cancelProject(String eventId, String projectId) =>
      'events/$eventId/projects/$projectId/cancel';

  // GET /v1/events/{event_id}/projects/my — returns the authenticated user's
  // own project submission for the event.
  static String myProject(String eventId) => 'events/$eventId/projects/my';

  // Cover image endpoints — only one cover per project, auto-replaced on
  // re-upload.
  static String coverImage(String eventId, String projectId) =>
      'events/$eventId/projects/$projectId/cover';

  // Extra image endpoints — max 6 extra images per project.
  static String extraImages(String eventId, String projectId) =>
      'events/$eventId/projects/$projectId/images';

  static String extraImage(String eventId, String projectId, String imageId) =>
      'events/$eventId/projects/$projectId/images/$imageId';
}
