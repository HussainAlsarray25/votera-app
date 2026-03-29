import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Checks connectivity by hitting a lightweight endpoint (defaults to
/// Google's generate_204) with a plain [Dio] instance that has no
/// interceptors -- so auth headers are never leaked to external URLs.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required this.connectivityUrl});

  final String connectivityUrl;

  // Standalone Dio with no interceptors, used only for connectivity.
  final Dio _dio = Dio();

  @override
  Future<bool> get isConnected async {
    // On web, cross-origin HEAD requests to external URLs (e.g. Google's
    // generate_204) are blocked by the browser's CORS policy before they
    // reach the network, making this check always return false.
    // Skip the pre-check on web and let Dio surface real network errors.
    if (kIsWeb) return true;

    // On mobile networks (especially on initial connection), a single
    // tight timeout can produce a false "no internet" result. We attempt
    // the check twice before giving up, giving slow connections a fair chance.
    const maxAttempts = 2;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _dio
            .head<void>(
              connectivityUrl,
              options: Options(validateStatus: (_) => true),
            )
            .timeout(const Duration(seconds: 10));
        final connected = response.statusCode != null;
        if (kDebugMode) {
          print(
            'NetworkInfo: check -> $connected (${response.statusCode})'
            ' on attempt $attempt',
          );
        }
        return connected;
      } on DioException catch (e) {
        // If the server replied with any status, the network is up.
        if (e.response != null) return true;
        // On the last attempt, give up and report no connection.
        if (attempt == maxAttempts) return false;
        // Otherwise, wait briefly and retry — the mobile radio may still be
        // waking up.
        await Future<void>.delayed(const Duration(seconds: 2));
      } on Exception catch (_) {
        if (attempt == maxAttempts) return false;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    return false;
  }
}
