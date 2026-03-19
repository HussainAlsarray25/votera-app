import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:votera/core/di/injection_container.dart' as di;
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

Future<void> _setupSystemPreferences() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
}
