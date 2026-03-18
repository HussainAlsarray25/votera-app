import 'package:votera/core/network/api_client.dart';

/// Contract for the remote category data source.
/// Returning raw maps keeps the data source ignorant of domain types,
/// so parsing logic stays in the model layer where it belongs.
abstract class CategoryRemoteDataSource {
  /// Fetches a page of categories from GET /v1/categories.
  Future<Map<String, dynamic>> getCategories({
    required int page,
    required int size,
  });

  /// Fetches a single category from GET /v1/categories/{id}.
  Future<Map<String, dynamic>> getCategoryById(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  const CategoryRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getCategories({
    required int page,
    required int size,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/categories',
      queryParameters: {'page': page, 'size': size},
    );
    // The categories endpoint returns the paginated envelope directly,
    // with no outer wrapper, so we can return the body as-is.
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/v1/categories/$id',
    );
    return response.data!;
  }
}
