import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/participants/data/models/participant_model.dart';

abstract class ApplicationRemoteDataSource {
  /// GET /v1/events/{event_id}/applications?page={page}&size={size}
  Future<PaginatedResponse<ApplicationModel>> getApplications({
    required String eventId,
    required int page,
    required int size,
  });

  /// POST /v1/events/{event_id}/applications
  /// Body: {team_id}
  Future<ApplicationModel> submitApplication({
    required String eventId,
    required String teamId,
  });

  /// GET /v1/events/{event_id}/applications/my?team_id={teamId}
  Future<ApplicationModel> getMyApplication({
    required String eventId,
    required String teamId,
  });
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  const ApplicationRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<PaginatedResponse<ApplicationModel>> getApplications({
    required String eventId,
    required int page,
    required int size,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/events/$eventId/applications',
      queryParameters: {'page': page, 'size': size},
    );
    return PaginatedResponse.fromJson(
      response.data!,
      ApplicationModel.fromJson,
    );
  }

  @override
  Future<ApplicationModel> submitApplication({
    required String eventId,
    required String teamId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/v1/events/$eventId/applications',
      data: {'team_id': teamId},
    );
    return ApplicationModel.fromJson(response.data!);
  }

  @override
  Future<ApplicationModel> getMyApplication({
    required String eventId,
    required String teamId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/events/$eventId/applications/my',
      queryParameters: {'team_id': teamId},
    );
    return ApplicationModel.fromJson(response.data!);
  }
}
