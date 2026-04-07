import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler required by Firebase for background messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
  }
}

/// Platform-agnostic push notification service wrapping Firebase Cloud Messaging.
/// Avoids dart:io by using kIsWeb and defaultTargetPlatform.
class FirebasePushService {
  FirebasePushService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _localNotifications;

  /// Initializes FCM and local notification channels.
  Future<void> initialize() async {
    // Background message handling is not supported on web — Firebase web uses
    // a service worker instead. Calling this on web throws an UnimplementedError
    // inside runZonedGuarded, which silently stops initialization (white screen).
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    // Local notifications are not supported on web.
    if (!kIsWeb) {
      await _setupLocalNotifications();
    }

    // Listen for foreground messages and display them as local notifications.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Requests notification permission from the user.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Returns the current FCM token for this device.
  Future<String?> getToken() async {
    if (kIsWeb) {
      // Web requires a VAPID key configured in Firebase console.
      // Pass it here when ready: _messaging.getToken(vapidKey: 'YOUR_KEY');
      return _messaging.getToken();
    }
    return _messaging.getToken();
  }

  /// Deletes the current FCM token from this device.
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  /// Stream that fires whenever FCM issues a new token (e.g. after refresh).
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Stream of foreground messages.
  Stream<RemoteMessage> onForegroundMessage() {
    return FirebaseMessaging.onMessage;
  }

  /// Stream of messages that were tapped by the user to open the app.
  Stream<RemoteMessage> onMessageOpenedApp() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  /// Returns the message that caused the app to open from a terminated state.
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  /// Returns a platform name suitable for the API token registration.
  String getPlatformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  /// Shows an immediate local notification. Used for in-app events such as
  /// Telegram login completion where the user may be in another app.
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb || _localNotifications == null) return;

    await _localNotifications!.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'votera_notifications',
          'Votera Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _setupLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android notification channel for high-importance notifications.
    const androidChannel = AndroidNotificationChannel(
      'votera_notifications',
      'Votera Notifications',
      description: 'Notifications from Votera',
      importance: Importance.high,
    );

    await _localNotifications!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(initSettings);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // On web, FCM handles display automatically.
    if (kIsWeb || _localNotifications == null) return;

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'votera_notifications',
          'Votera Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
