class AppConstants {
  AppConstants._();

  // API
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Pagination
  static const int defaultPageSize = 20;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String onboardingCompleteKey = 'onboarding_complete';
}
