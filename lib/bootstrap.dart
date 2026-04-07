import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:votera/core/di/injection_container.dart' as di;
import 'package:votera/core/router/app_router.dart';
import 'package:votera/core/services/firebase_push_service.dart';
import 'package:votera/features/notification/presentation/cubit/push_notification_cubit.dart';
import 'package:votera/firebase_options.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      log('onChange(${bloc.runtimeType}, $change)');
    }
  }

  @override
  void onError(
    BlocBase<dynamic> bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Use clean URLs on web (removes the # from all routes).
  // Must be called before any Flutter binding is initialized.
  usePathUrlStrategy();

  await runZonedGuarded(
    () async {
      BindingBase.debugZoneErrorsAreFatal = false;

      WidgetsFlutterBinding.ensureInitialized();

      await _setupErrorHandling();
      await _setupSystemPreferences();

      // Initialize Firebase before DI so services can use it.
      // Use existing app on hot restart to avoid duplicate-app error.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      Bloc.observer = const AppBlocObserver();

      await di.init();

      // Initialize push service after DI is ready.
      await di.sl<FirebasePushService>().initialize();

      // Eagerly create PushNotificationCubit so it starts listening
      // to auth state changes immediately.
      di.sl<PushNotificationCubit>();

      // Listen for votera:// deep links so the Telegram bot can return
      // the user to the app after login.
      await _setupDeepLinks();

      runApp(await builder());
    },
    (error, stackTrace) {
      log('Uncaught error: $error', stackTrace: stackTrace);
    },
  );
}

Future<void> _setupErrorHandling() async {
  FlutterError.onError = (details) {
    log(
      'Flutter Error: ${details.exceptionAsString()}',
      stackTrace: details.stack,
    );

    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log('Platform Error: $error', stackTrace: stack);
    return true;
  };
}

/// Initializes the app_links listener for custom URL scheme handling.
/// Handles both cold-start links (app was closed) and warm links (app was
/// in the background when the link was tapped).
Future<void> _setupDeepLinks() async {
  final appLinks = AppLinks();
  final appRouter = di.sl<AppRouter>();

  // Cold start: app was launched directly from the link.
  final initialLink = await appLinks.getInitialLink();
  if (initialLink != null) {
    _handleDeepLink(initialLink, appRouter);
  }

  // Warm start: app was already running or in the background.
  appLinks.uriLinkStream.listen((uri) {
    _handleDeepLink(uri, appRouter);
  });
}

/// Routes an incoming deep link URI to the correct app screen.
/// Handles: votera://home, votera://project/{eventId}/{projectId}
void _handleDeepLink(Uri uri, AppRouter appRouter) {
  if (uri.scheme != 'votera') return;

  switch (uri.host) {
    case 'home':
      appRouter.router.go('/home');
    case 'project':
      // Expected format: votera://project/{eventId}/{projectId}
      final segments = uri.pathSegments;
      if (segments.length == 2) {
        appRouter.router.go('/project/${segments[0]}/${segments[1]}');
      }
  }
}

Future<void> _setupSystemPreferences() async {
  // SystemChrome APIs are mobile-only. Calling them on web throws a
  // MissingPluginException that gets swallowed by runZonedGuarded, which
  // prevents runApp() from ever being reached — causing a white screen on iOS.
  if (kIsWeb) return;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
}
