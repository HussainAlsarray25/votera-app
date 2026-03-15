import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:votera/core/di/injection_container.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final dio = sl<Dio>();
      final response = await dio
          .head<void>('')
          .timeout(const Duration(seconds: 5));
      final connected = (response.statusCode ?? 500) < 500;
      if (kDebugMode) {
        print('NetworkInfo: check -> $connected (${response.statusCode})');
      }
      return connected;
    } on Exception catch (_) {
      return false;
    }
  }
}
