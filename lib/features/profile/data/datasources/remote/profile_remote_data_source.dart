import 'package:votera/core/network/api_client.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>('/profile');
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;

    final response = await apiClient.put<Map<String, dynamic>>(
      '/profile',
      data: data,
    );
    return response.data!;
  }
}
