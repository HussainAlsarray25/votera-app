import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/projects/data/datasources/remote/project_endpoints.dart';
import 'package:votera/features/projects/data/models/media_upload_response_model.dart';
import 'package:votera/features/projects/data/models/project_model.dart';

abstract class ProjectRemoteDataSource {
  /// GET /v1/events/{event_id}/projects?page&size&title&category_id
  Future<Map<String, dynamic>> getProjects({
    required String eventId,
    required int page,
    required int size,
    String? title,
    String? categoryId,
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
    String? teamId,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
    List<String>? categoryIds,
  });

  /// PUT /v1/events/{event_id}/projects/{id}
  Future<ProjectModel> updateProject({
    required String eventId,
    required String projectId,
    String? title,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
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

  /// POST /v1/events/{event_id}/projects/{id}/cancel
  Future<ProjectModel> cancelProject({
    required String eventId,
    required String projectId,
  });

  /// GET /v1/events/{event_id}/projects/my
  /// Pass [teamId] when the user belongs to multiple teams.
  Future<ProjectModel> getMyProject({
    required String eventId,
    String? teamId,
  });

  /// POST /v1/events/{event_id}/projects/{id}/cover
  /// Sends raw image bytes. If a cover already exists it is replaced.
  Future<MediaUploadResponseModel> uploadCover({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  });

  /// DELETE /v1/events/{event_id}/projects/{id}/cover
  Future<void> deleteCover({
    required String eventId,
    required String projectId,
  });

  /// POST /v1/events/{event_id}/projects/{id}/images
  /// Sends raw image bytes. Returns 409 when the 6-image limit is reached.
  Future<MediaUploadResponseModel> uploadExtraImage({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  });

  /// DELETE /v1/events/{event_id}/projects/{id}/images/{image_id}
  Future<void> deleteExtraImage({
    required String eventId,
    required String projectId,
    required String imageId,
  });

  /// DELETE /v1/events/{event_id}/projects/{id}
  Future<void> deleteProject({
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
    String? title,
    String? categoryId,
  }) async {
    final query = <String, dynamic>{'page': page, 'size': size};
    if (title != null && title.isNotEmpty) query['title'] = title;
    if (categoryId != null) query['category_id'] = categoryId;

    final response = await apiClient.get<Map<String, dynamic>>(
      ProjectEndpoints.projects(eventId),
      queryParameters: query,
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
    String? teamId,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
    List<String>? categoryIds,
  }) async {
    // Only include optional fields when provided — the API ignores null keys.
    final body = <String, dynamic>{'title': title};
    if (teamId != null) body['team_id'] = teamId;
    if (description != null) body['description'] = description;
    if (repoUrl != null) body['repo_url'] = repoUrl;
    if (demoUrl != null) body['demo_url'] = demoUrl;
    if (techStack != null) body['tech_stack'] = techStack;
    if (categoryIds != null && categoryIds.isNotEmpty) {
      body['category_ids'] = categoryIds;
    }

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
    String? techStack,
  }) async {
    // Only include fields that are explicitly being changed.
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (repoUrl != null) body['repo_url'] = repoUrl;
    if (demoUrl != null) body['demo_url'] = demoUrl;
    if (techStack != null) body['tech_stack'] = techStack;

    final response = await apiClient.put<Map<String, dynamic>>(
      ProjectEndpoints.projectById(eventId, projectId),
      data: body,
    );
    return ProjectModel.fromJson(response.data!);
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

  @override
  Future<ProjectModel> cancelProject({
    required String eventId,
    required String projectId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ProjectEndpoints.cancelProject(eventId, projectId),
    );
    return ProjectModel.fromJson(response.data!);
  }

  @override
  Future<ProjectModel> getMyProject({
    required String eventId,
    String? teamId,
  }) async {
    final query = teamId != null ? <String, dynamic>{'team_id': teamId} : null;
    final response = await apiClient.get<Map<String, dynamic>>(
      ProjectEndpoints.myProject(eventId),
      queryParameters: query,
    );
    return ProjectModel.fromJson(response.data!);
  }

  @override
  Future<MediaUploadResponseModel> uploadCover({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  }) async {
    // Send image bytes as the raw request body. The auth interceptor adds the
    // Bearer token; we override Content-Type to the image MIME type so the
    // server can validate the format before saving.
    final response = await apiClient.post<Map<String, dynamic>>(
      ProjectEndpoints.coverImage(eventId, projectId),
      data: bytes,
      options: Options(
        contentType: contentType,
        headers: {'Content-Length': bytes.length},
      ),
    );
    return MediaUploadResponseModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteCover({
    required String eventId,
    required String projectId,
  }) async {
    await apiClient.delete<void>(
      ProjectEndpoints.coverImage(eventId, projectId),
    );
  }

  @override
  Future<MediaUploadResponseModel> uploadExtraImage({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  }) async {
    // Same raw-bytes pattern as cover upload.
    final response = await apiClient.post<Map<String, dynamic>>(
      ProjectEndpoints.extraImages(eventId, projectId),
      data: bytes,
      options: Options(
        contentType: contentType,
        headers: {'Content-Length': bytes.length},
      ),
    );
    return MediaUploadResponseModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteExtraImage({
    required String eventId,
    required String projectId,
    required String imageId,
  }) async {
    await apiClient.delete<void>(
      ProjectEndpoints.extraImage(eventId, projectId, imageId),
    );
  }

  @override
  Future<void> deleteProject({
    required String eventId,
    required String projectId,
  }) async {
    await apiClient.delete<void>(
      ProjectEndpoints.projectById(eventId, projectId),
    );
  }
}
