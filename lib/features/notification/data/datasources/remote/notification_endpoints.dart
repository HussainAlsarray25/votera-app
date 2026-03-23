/// Centralized endpoint paths for the notifications feature.
/// All paths are relative (no leading slash, no version prefix).
class NotificationEndpoints {
  const NotificationEndpoints._();

  static const String notifications = 'notifications';
  static const String readAll = 'notifications/read-all';
  static const String unreadCount = 'notifications/unread-count';
  static const String tokens = 'notifications/tokens';

  static String markAsRead(String id) => 'notifications/$id/read';
  static String removeToken(String token) => 'notifications/tokens/$token';
}
