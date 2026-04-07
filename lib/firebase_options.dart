import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration generated from google-services.json.
/// iOS and web options must be updated once their Firebase apps are created.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions is not configured for ${defaultTargetPlatform.name}. '
          'Run "flutterfire configure" to generate this file.',
        );
    }
  }

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'AIzaSyDosjBQham5NhekGVSWRrS-37YOIkUWn4s',
    appId: '1:783622128925:android:306a88b3892b55a9260df4',
    messagingSenderId: '783622128925',
    projectId: 'votera-platform',
    storageBucket: 'votera-platform.firebasestorage.app',
  );

  // TODO: Replace with actual iOS Firebase app values.
  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'AIzaSyDosjBQham5NhekGVSWRrS-37YOIkUWn4s',
    appId: '1:783622128925:android:306a88b3892b55a9260df4',
    messagingSenderId: '783622128925',
    projectId: 'votera-platform',
    storageBucket: 'votera-platform.firebasestorage.app',
    iosBundleId: 'votera.space',
  );

  // Web Firebase app values — appId must come from the Firebase Console web app,
  // not from the Android or iOS app. Run "flutterfire configure" or copy the
  // config snippet from: Firebase Console > Project settings > Your apps > Web app.
  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: 'AIzaSyDosjBQham5NhekGVSWRrS-37YOIkUWn4s',
    appId: '1:783622128925:web:REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '783622128925',
    projectId: 'votera-platform',
    storageBucket: 'votera-platform.firebasestorage.app',
  );
}
