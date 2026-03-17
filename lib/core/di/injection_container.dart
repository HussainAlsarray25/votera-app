import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:votera/core/config/app_config.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/auth_interceptor.dart';
import 'package:votera/core/network/dio_api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/router/app_router.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';
import 'package:votera/features/authentication/data/services/token_service_auth_provider.dart';
import 'package:votera/features/authentication/di/auth_injection.dart';
import 'package:votera/features/exhibitions/di/exhibitions_injection.dart';
import 'package:votera/features/home/di/home_injection.dart';
import 'package:votera/features/notification/di/notification_injection.dart';
import 'package:votera/features/onboarding/di/onboarding_injection.dart';
import 'package:votera/features/profile/di/profile_injection.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  try {
    const appConfig = AppConfig.instance;

    await _initExternalDependencies(appConfig);
    _initCore();
    _initFeatures();

    if (kDebugMode) {
      print('Dependency injection initialized successfully');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Failed to initialize dependency injection: $e');
      print('Stack trace: $stackTrace');
    }
    rethrow;
  }
}

Future<void> _initExternalDependencies(AppConfig config) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences)
    ..registerLazySingleton<TokenService>(() => const SecureTokenService())
    ..registerLazySingleton<AuthTokenProvider>(
      () => TokenServiceAuthProvider(tokenService: sl<TokenService>()),
    )
    ..registerLazySingleton<Dio>(() {
      final authTokenProvider = sl<AuthTokenProvider>();
      final dio = Dio()
        ..options = BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        );

      dio.interceptors.add(AuthInterceptor(
        dio: dio,
        authTokenProvider: authTokenProvider,
      ),);

      if (config.enableLogging) {
        dio.interceptors.add(
          PrettyDioLogger(compact: false),
        );
      }
      return dio;
    })
    ..registerLazySingleton<ApiClient>(() => DioApiClient(dio: sl<Dio>()))
    ..registerLazySingleton<AppRouter>(AppRouter.new);
}

void _initCore() {
  sl.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);
}

void _initFeatures() {
  initAuthFeature(sl);
  initProfileFeature(sl);
  initNotificationFeature(sl);
  initOnboardingFeature(sl);
  initHomeFeature(sl);
  initExhibitionsFeature(sl);
}

Future<void> reset() async {
  await sl.reset();
}
