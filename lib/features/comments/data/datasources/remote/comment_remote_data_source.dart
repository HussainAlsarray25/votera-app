import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/comments/data/datasources/remote/comment_endpoints.dart';

/// Contract for the comments remote data source.
/// Returns raw JSON maps so the repository can convert them to typed models
/// without the data source being aware of domain entities.
abstract class CommentRemoteDataSource {
  /// GET /v1/projects/{projectId}/comments?page=&size=
  /// Returns the raw paginated envelope: {items[], page, size, total}.
  Future<Map<String, dynamic>> getComments({
    required String projectId,
    required int page,
    required int size,
  });

  /// POST /v1/projects/{projectId}/comments with {score, text}
  /// Returns the created CommentResponse as a raw map.
  Future<Map<String, dynamic>> postComment({
    required String projectId,
    required String text,
    required int score,
  });

  /// PUT /v1/projects/{projectId}/comments/{commentId} with {body}
  /// Returns the updated CommentResponse as a raw map.
  Future<Map<String, dynamic>> updateComment({
    required String projectId,
    required String commentId,
    required String body,
  });

  /// DELETE /v1/projects/{projectId}/comments/{commentId}
  /// The server returns no body on success.
  Future<void> deleteComment({
    required String projectId,
    required String commentId,
  });
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  const CommentRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getComments({
    required String projectId,
    required int page,
    required int size,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      CommentEndpoints.comments(projectId),
      queryParameters: {'page': page, 'size': size},
    );
    // Non-identity module: response body is the paginated envelope directly.
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> postComment({
    required String projectId,
    required String text,
    required int score,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      CommentEndpoints.comments(projectId),
      data: {'score': score, 'text': text},
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> updateComment({
    required String projectId,
    required String commentId,
    required String body,
  }) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      CommentEndpoints.commentById(projectId, commentId),
      data: {'body': body},
    );
    return response.data!;
  }

  @override
  Future<void> deleteComment({
    required String projectId,
    required String commentId,
  }) async {
    await apiClient.delete<void>(
      CommentEndpoints.commentById(projectId, commentId),
    );
  }
}
