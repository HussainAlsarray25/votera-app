import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/ratings/data/datasources/remote/rating_endpoints.dart';
import 'package:votera/features/ratings/data/models/rating_model.dart';
import 'package:votera/features/ratings/data/models/rating_summary_model.dart';

abstract class RatingRemoteDataSource {
  /// PUT /v1/projects/{project_id}/rating
  Future<RatingModel> rateProject({
    required String projectId,
    required int score,
  });

  /// GET /v1/projects/{project_id}/rating
  Future<RatingSummaryModel> getRatingSummary(String projectId);

  /// GET /v1/projects/{project_id}/rating/my
  Future<RatingModel> getMyRating(String projectId);
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  const RatingRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<RatingModel> rateProject({
    required String projectId,
    required int score,
  }) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      RatingEndpoints.rating(projectId),
      data: {'score': score},
    );
    return RatingModel.fromJson(response.data!);
  }

  @override
  Future<RatingSummaryModel> getRatingSummary(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      RatingEndpoints.rating(projectId),
    );
    // The API wraps the payload in { "success": true, "data": { ... } }.
    final body = response.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return RatingSummaryModel.fromJson(data);
  }

  @override
  Future<RatingModel> getMyRating(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      RatingEndpoints.myRating(projectId),
    );
    return RatingModel.fromJson(response.data!);
  }
}
