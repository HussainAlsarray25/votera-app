import 'dart:async';

import 'package:dio/dio.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.authTokenProvider,
  });

  final Dio dio;
  final AuthTokenProvider authTokenProvider;

  // Prevents multiple concurrent refresh calls when several requests
  // receive 401 at the same time. Only the first caller does the actual
  // refresh; the rest await the same Completer.
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

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
        !_isAuthRequest(err.requestOptions)) {
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

  bool _isAuthRequest(RequestOptions options) {
    return options.path.contains('auth/');
  }

  Future<bool> _refreshToken() async {
    // Queue behind any ongoing refresh rather than firing a second one.
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    var success = false;
    try {
      final refreshToken = await authTokenProvider.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final response = await dio.post<Map<String, dynamic>>(
          'auth/refresh',
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
            success = true;
          }
        }
      }
    } on DioException {
      success = false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter!.complete(success);
      _refreshCompleter = null;
    }

    return success;
  }
}
