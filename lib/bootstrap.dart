import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:votera/core/di/injection_container.dart' as di;

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

      Bloc.observer = const AppBlocObserver();

      await di.init();

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
