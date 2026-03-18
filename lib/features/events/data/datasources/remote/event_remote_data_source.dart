import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';

abstract class EventRemoteDataSource {
  /// Calls GET /v1/events with optional status filter and pagination.
  Future<Map<String, dynamic>> getEvents({
    EventStatus? status,
    required int page,
    required int size,
  });

  /// Calls GET /v1/events/{id}.
  Future<Map<String, dynamic>> getEventById(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  const EventRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getEvents({
    EventStatus? status,
    required int page,
    required int size,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
      if (status != null) 'status': status.name,
    };

    final response = await apiClient.get<Map<String, dynamic>>(
      '/events',
      queryParameters: queryParameters,
    );
    return response.data ?? {};
  }

  @override
  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/events/$id',
    );
    return response.data ?? {};
  }
}
