import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:votera/core/config/app_config.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/core/domain/services/location_service.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/auth_interceptor.dart';
import 'package:votera/core/network/dio_api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/router/app_router.dart';
import 'package:votera/core/services/firebase_push_service.dart';
import 'package:votera/core/services/location_service_impl.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';
import 'package:votera/features/authentication/data/services/token_service_auth_provider.dart';
import 'package:votera/features/authentication/di/auth_injection.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/push_notification_cubit.dart';
import 'package:votera/features/categories/di/categories_injection.dart';
import 'package:votera/features/certifications/di/certifications_injection.dart';
import 'package:votera/features/comments/di/comments_injection.dart';
import 'package:votera/features/events/di/events_injection.dart';
import 'package:votera/features/exhibitions/di/exhibitions_injection.dart';
import 'package:votera/features/home/di/home_injection.dart';
import 'package:votera/features/notification/di/notification_injection.dart';
import 'package:votera/features/onboarding/di/onboarding_injection.dart';
import 'package:votera/features/participants/di/participants_injection.dart';
import 'package:votera/features/profile/di/profile_injection.dart';
import 'package:votera/features/projects/di/projects_injection.dart';
import 'package:votera/features/ratings/di/ratings_injection.dart';
import 'package:votera/features/rankings/di/rankings_injection.dart';
import 'package:votera/features/participant_forms/di/forms_injection.dart';
import 'package:votera/features/teams/di/teams_injection.dart';
import 'package:votera/features/force_update/di/force_update_injection.dart';
import 'package:votera/features/settings/di/settings_injection.dart';
import 'package:votera/features/voting/di/voting_injection.dart';

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
          // sendTimeout only applies to requests with a body (POST/PUT/PATCH).
          // On web, Dio warns if sendTimeout is set on bodyless requests (GET/HEAD),
          // so it is omitted here and applied per-request when needed.
        );

      // Logger goes first so it captures both requests and error responses
      // before the auth interceptor short-circuits on 401.
      if (config.enableLogging) {
        dio.interceptors.add(
          PrettyDioLogger(compact: false, requestBody: true),
        );
      }

      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          authTokenProvider: authTokenProvider,
        ),
      );
      return dio;
    })
    ..registerLazySingleton<ApiClient>(() => DioApiClient(dio: sl<Dio>()))
    ..registerLazySingleton<AppRouter>(AppRouter.new)
    ..registerLazySingleton<FirebasePushService>(FirebasePushService.new);
}

void _initCore() {
  sl
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(
        connectivityUrl: AppConfig.instance.connectivityUrl,
      ),
    )
    ..registerLazySingleton<LocationService>(LocationServiceImpl.new);
}

void _initFeatures() {
  initForceUpdateFeature(sl);

  initAuthFeature(sl);
  initProfileFeature(sl);
  initNotificationFeature(sl);

  // Wire up the pre-logout callback after both singletons are registered.
  // AuthCubit calls this before clearing tokens so the push token DELETE
  // request still has a valid Authorization header.
  sl<AuthCubit>().setPreLogoutCallback(
    sl<PushNotificationCubit>().unregisterToken,
  );

  initOnboardingFeature(sl);
  initHomeFeature(sl);
  initCategoriesFeature(sl);
  initEventsFeature(sl);
  initExhibitionsFeature(sl);
  initProjectsFeature(sl);
  initVotingFeature(sl);
  initCommentsFeature(sl);
  initParticipantsFeature(sl);
  initRankingsFeature(sl);
  initTeamsFeature(sl);
  initCertificationsFeature(sl);
  initRatingsFeature(sl);
  initFormsFeature(sl);
  initSettingsFeature(sl);
}

Future<void> reset() async {
  await sl.reset();
}
