/// Centralized endpoint paths for the notifications feature.
/// All paths are relative (no leading slash, no version prefix).
class NotificationEndpoints {
  const NotificationEndpoints._();

  static const String notifications = 'notifications';

  static String markAsRead(String id) => 'notifications/$id/read';
}
