import 'package:votera/core/network/api_version.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.connectivityUrl,
    required this.appName,
    required this.enableLogging,
  });

  final String apiBaseUrl;
  final String connectivityUrl;
  final String appName;
  final bool enableLogging;

  static const String _host = 'https://api.votera.space/api';

  static const AppConfig instance = AppConfig(
    apiBaseUrl: '$_host/${ApiVersion.current}/',
    // Using the app's own API host avoids relying on Google, which may be
    // blocked or unreliable in some regions (e.g. Iraq). If this endpoint
    // is reachable, the API itself is reachable.
    connectivityUrl: 'https://api.votera.space',
    appName: 'Votera',
    enableLogging: true,
  );
}
