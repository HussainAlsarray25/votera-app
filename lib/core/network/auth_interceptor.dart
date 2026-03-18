import 'package:dio/dio.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/features/authentication/data/datasources/remote/auth_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.authTokenProvider,
  });

  final Dio dio;
  final AuthTokenProvider authTokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    final token = await authTokenProvider.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !_isRefreshRequest(err.requestOptions)) {
      final currentRefreshToken = await authTokenProvider.getRefreshToken();
      final didRefresh = await _refreshToken();

      if (didRefresh) {
        final newToken = await authTokenProvider.getAccessToken();
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await dio.fetch<dynamic>(retryOptions);
          return handler.resolve(response);
        } on DioException {
          return handler.reject(err);
        }
      } else {
        if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
          return handler.reject(err);
        }
        await authTokenProvider.clearTokens();
        return handler.reject(err);
      }
    }

    handler.next(err);
  }

  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains(AuthEndpoints.refresh);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await authTokenProvider.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      // Uses the same Dio instance so the base URL is prepended,
      // resulting in: {baseUrl}/auth/refresh
      final response = await dio.post<Map<String, dynamic>>(
        AuthEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        final newAccessToken = data?['access_token']?.toString();
        final newRefreshToken = data?['refresh_token']?.toString();

        if (newAccessToken != null && newRefreshToken != null) {
          await authTokenProvider.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
      return false;
    } on DioException {
      return false;
    }
  }
}
