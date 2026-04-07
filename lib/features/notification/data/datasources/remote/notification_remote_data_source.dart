import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/notification/data/datasources/remote/notification_endpoints.dart';

abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  });
  Future<void> removeDeviceToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      NotificationEndpoints.notifications,
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  /// POST /v1/notifications/{id}/read
  @override
  Future<void> markAsRead(String id) async {
    await apiClient.post<void>(NotificationEndpoints.markAsRead(id));
  }

  /// POST /v1/notifications/read-all
  @override
  Future<void> markAllAsRead() async {
    await apiClient.post<void>(NotificationEndpoints.readAll);
  }

  /// GET /v1/notifications/unread-count
  @override
  Future<int> getUnreadCount() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      NotificationEndpoints.unreadCount,
    );
    // The API wraps the payload in a 'data' envelope.
    // The count may be a bare int (data: 2) or a map (data: {count: 2}).
    final data = response.data?['data'];
    if (data is int) return data;
    if (data is Map) return data['count'] as int? ?? 0;
    // Fallback for servers that return count at the top level.
    return response.data?['count'] as int? ?? 0;
  }

  /// POST /v1/notifications/tokens
  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await apiClient.post<void>(
      NotificationEndpoints.tokens,
      data: {'token': token, 'platform': platform},
    );
  }

  /// DELETE /v1/notifications/tokens/{token}
  @override
  Future<void> removeDeviceToken(String token) async {
    await apiClient.delete<void>(NotificationEndpoints.removeToken(token));
  }
}
