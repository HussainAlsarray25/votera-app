import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/force_update/data/datasources/remote/app_version_endpoints.dart';

abstract class AppVersionRemoteDataSource {
  /// Fetches raw JSON from GET /v1/app-versions/latest.
  Future<Map<String, dynamic>> getLatestVersion();
}

class AppVersionRemoteDataSourceImpl implements AppVersionRemoteDataSource {
  const AppVersionRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getLatestVersion() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      AppVersionEndpoints.latestVersion,
    );
    // Unwrap standard data envelope: {"data": {...}}
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data ?? {};
  }
}
