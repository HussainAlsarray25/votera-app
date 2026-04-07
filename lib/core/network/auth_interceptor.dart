import 'dart:async';

import 'package:dio/dio.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';

/// Possible outcomes of a token refresh attempt.
enum _RefreshResult { success, invalidToken, serverError }

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.authTokenProvider,
  });

  final Dio dio;
  final AuthTokenProvider authTokenProvider;

  // Guards against multiple concurrent refresh calls when several requests
  // receive 401 simultaneously. The first caller performs the actual refresh;
  // subsequent callers wait on the same Completer.
  bool _isRefreshing = false;
  Completer<_RefreshResult>? _refreshCompleter;

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
      final result = await _refreshToken();

      switch (result) {
        case _RefreshResult.success:
          // Retry the original request with the new access token.
          final newToken = await authTokenProvider.getAccessToken();
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await dio.fetch<dynamic>(retryOptions);
            return handler.resolve(response);
          } on DioException {
            return handler.reject(err);
          }

        case _RefreshResult.invalidToken:
          // The refresh token is definitively rejected — clear state and
          // propagate so the app can redirect to login.
          await authTokenProvider.clearTokens();
          return handler.reject(err);

        case _RefreshResult.serverError:
          // Transient server error (5xx, network timeout). Keep existing
          // tokens intact so the user is not logged out on a momentary blip.
          return handler.reject(err);
      }
    }

    handler.next(err);
  }

  bool _isAuthRequest(RequestOptions options) {
    return options.path.contains('auth/');
  }

  Future<_RefreshResult> _refreshToken() async {
    // Queue behind any ongoing refresh rather than firing a second one.
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<_RefreshResult>();

    var result = _RefreshResult.serverError;
    try {
      final refreshToken = await authTokenProvider.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        result = _RefreshResult.invalidToken;
        return result;
      }

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
          result = _RefreshResult.success;
        }
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // A 401 from the refresh endpoint means the refresh token is invalid.
      // Any other error (5xx, timeout, network) is treated as transient.
      result = (status == 401)
          ? _RefreshResult.invalidToken
          : _RefreshResult.serverError;
    } finally {
      _isRefreshing = false;
      _refreshCompleter!.complete(result);
      _refreshCompleter = null;
    }

    return result;
  }
}
