import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/projects/data/datasources/remote/project_endpoints.dart';
import 'package:votera/features/projects/data/models/project_model.dart';
import 'package:votera/features/projects/data/models/upload_url_model.dart';

abstract class ProjectRemoteDataSource {
  /// GET /v1/events/{event_id}/projects?page&size
  Future<Map<String, dynamic>> getProjects({
    required String eventId,
    required int page,
    required int size,
  });

  /// GET /v1/events/{event_id}/projects/{id}
  Future<ProjectModel> getProjectById({
    required String eventId,
    required String projectId,
  });

  /// POST /v1/events/{event_id}/projects
  Future<ProjectModel> submitProject({
    required String eventId,
    required String title,
    String? description,
    String? repoUrl,
    String? demoUrl,
  });

  /// PUT /v1/events/{event_id}/projects/{id}
  Future<ProjectModel> updateProject({
    required String eventId,
    required String projectId,
    String? title,
    String? description,
    String? repoUrl,
    String? demoUrl,
  });

  /// POST /v1/events/{event_id}/projects/{id}/media/upload-url
  Future<UploadUrlModel> getUploadUrl({
    required String eventId,
    required String projectId,
    required String fileName,
    String? fileType,
  });

  /// GET /v1/scan/{token}
  Future<ProjectModel> scanProject(String token);

  /// POST /v1/events/{event_id}/projects/{id}/categories/{category_id}
  Future<void> addProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  });

  /// DELETE /v1/events/{event_id}/projects/{id}/categories/{category_id}
  Future<void> removeProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  });

  /// POST /v1/events/{event_id}/projects/{id}/submit
  Future<ProjectModel> finalizeProject({
    required String eventId,
    required String projectId,
  });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  const ProjectRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getProjects({
    required String eventId,
    required int page,
    required int size,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ProjectEndpoints.projects(eventId),
      queryParameters: {'page': page, 'size': size},
    );
    return response.data!;
  }

  @override
  Future<ProjectModel> getProjectById({
    required String eventId,
    required String projectId,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ProjectEndpoints.projectById(eventId, projectId),
    );
    return ProjectModel.fromJson(response.data!);
  }

  @override
  Future<ProjectModel> submitProject({
    required String eventId,
    required String title,
    String? description,
    String? repoUrl,
    String? demoUrl,
  }) async {
    // Only include optional fields when provided — the API ignores null keys.
    final body = <String, dynamic>{'title': title};
    if (description != null) body['description'] = description;
    if (repoUrl != null) body['repo_url'] = repoUrl;
    if (demoUrl != null) body['demo_url'] = demoUrl;

    final response = await apiClient.post<Map<String, dynamic>>(
      ProjectEndpoints.projects(eventId),
      data: body,
    );
    return ProjectModel.fromJson(response.data!);
  }

  @override
  Future<ProjectModel> updateProject({
    required String eventId,
    required String projectId,
    String? title,
    String? description,
    String? repoUrl,
    String? demoUrl,
  }) async {
    // Only include fields that are explicitly being changed.
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (repoUrl != null) body['repo_url'] = repoUrl;
    if (demoUrl != null) body['demo_url'] = demoUrl;

    final response = await apiClient.put<Map<String, dynamic>>(
      ProjectEndpoints.projectById(eventId, projectId),
      data: body,
    );
    return ProjectModel.fromJson(response.data!);
  }

  @override
  Future<UploadUrlModel> getUploadUrl({
    required String eventId,
    required String projectId,
    required String fileName,
    String? fileType,
  }) async {
    final body = <String, dynamic>{'file_name': fileName};
    if (fileType != null) body['file_type'] = fileType;

    final response = await apiClient.post<Map<String, dynamic>>(
      ProjectEndpoints.mediaUploadUrl(eventId, projectId),
      data: body,
    );
    return UploadUrlModel.fromJson(response.data!);
  }

  @override
  Future<ProjectModel> scanProject(String token) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ProjectEndpoints.scan(token),
    );
    return ProjectModel.fromJson(response.data!);
  }

  @override
  Future<void> addProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    await apiClient.post<void>(
      ProjectEndpoints.projectCategory(eventId, projectId, categoryId),
    );
  }

  @override
  Future<void> removeProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    await apiClient.delete<void>(
      ProjectEndpoints.projectCategory(eventId, projectId, categoryId),
    );
  }

  @override
  Future<ProjectModel> finalizeProject({
    required String eventId,
    required String projectId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ProjectEndpoints.submitProject(eventId, projectId),
    );
    return ProjectModel.fromJson(response.data!);
  }
}
