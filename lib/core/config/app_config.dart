class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
  });

  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;

  // TODO(dev): Update with your actual API base URL.
  static const AppConfig instance = AppConfig(
    apiBaseUrl: 'https://api.votera.com/api/v1',
    appName: 'Votera',
    enableLogging: true,
  );
}
