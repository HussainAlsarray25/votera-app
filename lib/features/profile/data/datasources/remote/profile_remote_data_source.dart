import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/profile/data/datasources/remote/profile_endpoints.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> updateUserProfile({String? fullName});
  /// Uploads [filePath] as the user's profile picture.
  /// Returns the new avatar URL on success.
  Future<String> uploadAvatar(String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    final response =
        await apiClient.get<Map<String, dynamic>>(ProfileEndpoints.me);
    // Identity module wraps response in {success, data}
    final body = response.data!;
    if (body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;

    final response = await apiClient.put<Map<String, dynamic>>(
      ProfileEndpoints.me,
      data: data,
    );
    final body = response.data!;
    if (body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });

    final response = await apiClient.post<Map<String, dynamic>>(
      ProfileEndpoints.avatar,
      data: formData,
    );

    final body = response.data!;
    // Response: { success: true, data: { "url": "https://..." } }
    final dataMap = (body['data'] as Map<String, dynamic>?) ?? {};
    final url = dataMap.values.whereType<String>().firstOrNull ?? '';
    return url;
  }
}
