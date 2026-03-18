import 'package:votera/core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  /// POST /auth/login with {identifier, secret}
  /// Returns the wrapped response: {success, data: {access_token, refresh_token}}
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String secret,
  });

  /// POST /auth/register with {username, email, password, display_name}
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  });

  /// POST /auth/login/verify with {identifier, code}
  Future<Map<String, dynamic>> verifyLogin({
    required String identifier,
    required String code,
  });

  /// POST /auth/logout
  Future<void> logout();

  /// POST /auth/password/change with {old_password, new_password}
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// POST /auth/password/reset with {email}
  Future<void> resetPassword({required String email});

  /// POST /auth/password/reset-confirm with {token, new_password}
  Future<void> confirmResetPassword({
    required String token,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String secret,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'identifier': identifier, 'secret': secret},
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> verifyLogin({
    required String identifier,
    required String code,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/login/verify',
      data: {'identifier': identifier, 'code': code},
    );
    return response.data!;
  }

  @override
  Future<void> logout() async {
    await apiClient.post<void>('/auth/logout');
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      '/auth/password/change',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await apiClient.post<Map<String, dynamic>>(
      '/auth/password/reset',
      data: {'email': email},
    );
  }

  @override
  Future<void> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      '/auth/password/reset-confirm',
      data: {'token': token, 'new_password': newPassword},
    );
  }
}
