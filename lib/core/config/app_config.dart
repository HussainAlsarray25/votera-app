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
    connectivityUrl: 'https://clients3.google.com/generate_204',
    appName: 'Votera',
    enableLogging: true,
  );
}
