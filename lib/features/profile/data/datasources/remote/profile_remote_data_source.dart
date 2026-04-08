import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/utils/image_content_type.dart';
import 'package:votera/features/profile/data/datasources/remote/profile_endpoints.dart';
import 'dart:typed_data';

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
    if (bytes == null || bytes.isEmpty) {
      throw ArgumentError('Avatar bytes must be provided');
    }

    final contentType = resolveImageContentType(
      filePath: filePath,
      fileName: fileName,
    );

    // Convert to Uint8List for better platform compatibility (especially web).
    final imageBytes = Uint8List.fromList(bytes);

    final response = await apiClient.post<Map<String, dynamic>>(
      ProfileEndpoints.avatar,
      data: imageBytes,
      options: Options(
        contentType: contentType,
        headers: {'Content-Length': imageBytes.length},
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Throw an Exception (not an Error) so the repository's on-Exception catch
    // can convert it into a Left(Failure) instead of crashing the whole app.
    final body = response.data;
    if (body == null) {
      throw Exception('Avatar upload returned an empty response');
    }
    // Response: { success: true, message: "...", data: { "url": "https://..." } }
    final dataMap = (body['data'] as Map<String, dynamic>?) ?? {};
    final url = (dataMap['url'] as String?) ?? '';
    return url;
  }
}
