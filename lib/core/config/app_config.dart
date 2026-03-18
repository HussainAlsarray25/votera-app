class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
  });

  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;

  static const AppConfig instance = AppConfig(
    apiBaseUrl: 'https://api.votera.space/api/v1',
    appName: 'Votera',
    enableLogging: true,
  );
}
