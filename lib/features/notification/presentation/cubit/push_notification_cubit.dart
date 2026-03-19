import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/services/firebase_push_service.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/notification/domain/usecases/register_device_token.dart';
import 'package:votera/features/notification/domain/usecases/remove_device_token.dart';
import 'package:votera/features/notification/presentation/cubit/push_notification_state.dart';

/// Singleton cubit that manages FCM token lifecycle.
/// Listens to AuthCubit to auto-register/unregister tokens on login/logout.
class PushNotificationCubit extends Cubit<PushNotificationState> {
  PushNotificationCubit({
    required this.pushService,
    required this.authCubit,
    required this.registerDeviceToken,
    required this.removeDeviceToken,
  }) : super(const PushNotificationInitial()) {
    _authSubscription = authCubit.stream.listen(_onAuthStateChanged);
    _tokenRefreshSubscription =
        pushService.onTokenRefresh.listen(_onTokenRefresh);
  }

  final FirebasePushService pushService;
  final AuthCubit authCubit;
  final RegisterDeviceToken registerDeviceToken;
  final RemoveDeviceToken removeDeviceToken;

  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _currentToken;

  /// Called when the auth state changes. Registers token on login,
  /// unregisters on logout.
  Future<void> _onAuthStateChanged(dynamic authState) async {
    if (authState is AuthAuthenticated) {
      await _registerToken();
    } else if (authState is AuthInitial) {
      await _unregisterToken();
    }
  }

  /// Called when FCM issues a new token. Re-registers with the backend.
  Future<void> _onTokenRefresh(String newToken) async {
    // Only re-register if the user is authenticated.
    if (authCubit.state is! AuthAuthenticated) return;

    _currentToken = newToken;
    await _sendTokenToBackend(newToken);
  }

  Future<void> _registerToken() async {
    final granted = await pushService.requestPermission();
    if (!granted) {
      if (kDebugMode) print('Push notification permission denied');
      return;
    }

    final token = await pushService.getToken();
    if (token == null) {
      if (kDebugMode) print('Failed to get FCM token');
      return;
    }

    _currentToken = token;
    await _sendTokenToBackend(token);
  }

  Future<void> _sendTokenToBackend(String token) async {
    final platform = pushService.getPlatformName();
    final result = await registerDeviceToken(
      RegisterDeviceTokenParams(token: token, platform: platform),
    );
    result.fold(
      (failure) {
        if (kDebugMode) print('Failed to register push token: ${failure.message}');
        emit(PushNotificationError(message: failure.message));
      },
      (_) => emit(PushNotificationRegistered(token: token)),
    );
  }

  Future<void> _unregisterToken() async {
    if (_currentToken == null) return;

    final token = _currentToken!;
    _currentToken = null;

    final result = await removeDeviceToken(
      RemoveDeviceTokenParams(token: token),
    );
    result.fold(
      (failure) {
        if (kDebugMode) print('Failed to remove push token: ${failure.message}');
      },
      (_) => emit(const PushNotificationUnregistered()),
    );

    await pushService.deleteToken();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    return super.close();
  }
}
