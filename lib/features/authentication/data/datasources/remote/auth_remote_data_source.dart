import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/authentication/data/datasources/remote/auth_endpoints.dart';

abstract class AuthRemoteDataSource {
  /// POST /auth/login with {identifier, secret}
  /// Returns the wrapped response: {success, data: {access_token, refresh_token}}
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String secret,
  });

  /// POST /auth/register with {full_name, identifier, password}
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String identifier,
    required String password,
  });

  /// POST /auth/register/verify with {identifier, code}
  /// Returns the wrapped response with access_token / refresh_token on success.
  Future<Map<String, dynamic>> verifyRegistration({
    required String identifier,
    required String code,
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

  /// POST /auth/telegram/request-link
  /// Returns the wrapped response: {success, data: {token, link}}
  Future<Map<String, dynamic>> requestTelegramLink();

  /// GET /auth/telegram/status?token={uuid}
  /// Returns the wrapped response: {success, data: {status, access_token, refresh_token}}
  Future<Map<String, dynamic>> getTelegramStatus(String token);
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
      AuthEndpoints.login,
      data: {'identifier': identifier, 'secret': secret},
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.register,
      data: {
        'full_name': fullName,
        'identifier': identifier,
        'password': password,
      },
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> verifyRegistration({
    required String identifier,
    required String code,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.registerVerify,
      data: {'identifier': identifier, 'code': code},
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> verifyLogin({
    required String identifier,
    required String code,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.verifyLogin,
      data: {'identifier': identifier, 'code': code},
    );
    return response.data!;
  }

  @override
  Future<void> logout() async {
    await apiClient.post<void>(AuthEndpoints.logout);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.resetPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.resetPasswordConfirm,
      data: {'token': token, 'new_password': newPassword},
    );
  }

  @override
  Future<Map<String, dynamic>> requestTelegramLink() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AuthEndpoints.telegramRequestLink,
      queryParameters: {'platform': kIsWeb ? 'web' : 'mobile'},
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getTelegramStatus(String token) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      AuthEndpoints.telegramStatus,
      queryParameters: {'token': token},
    );
    return response.data!;
  }
}
