import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/profile/data/datasources/remote/profile_endpoints.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> updateUserProfile({String? fullName});
  /// Uploads a profile picture. Use [filePath] on mobile/desktop and
  /// [bytes] + [fileName] on web where a file path is not available.
  Future<String> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? fileName,
  });
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
  Future<String> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    final MultipartFile avatarFile;
    if (filePath != null) {
      // Mobile / desktop — read directly from the file system path.
      avatarFile = await MultipartFile.fromFile(filePath, filename: fileName);
    } else if (bytes != null) {
      // Web — file path is unavailable, use the in-memory bytes instead.
      avatarFile = MultipartFile.fromBytes(bytes, filename: fileName ?? 'avatar');
    } else {
      throw ArgumentError('Either filePath or bytes must be provided');
    }

    final formData = FormData.fromMap({'avatar': avatarFile});

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
