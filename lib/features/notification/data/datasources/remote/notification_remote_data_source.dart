import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/notification/data/datasources/remote/notification_endpoints.dart';

abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await apiClient.get<List<dynamic>>(NotificationEndpoints.notifications);
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> markAsRead(String id) async {
    await apiClient.put<void>(NotificationEndpoints.markAsRead(id));
  }
}
