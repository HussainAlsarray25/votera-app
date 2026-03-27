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

    try {
      final response = await _dio
          .head<void>(
            connectivityUrl,
            options: Options(validateStatus: (_) => true),
          )
          .timeout(const Duration(seconds: 5));
      final connected = response.statusCode != null;
      if (kDebugMode) {
        print('NetworkInfo: check -> $connected (${response.statusCode})');
      }
      return connected;
    } on DioException catch (e) {
      if (e.response != null) return true;
      return false;
    } on Exception catch (_) {
      return false;
    }
  }
}
