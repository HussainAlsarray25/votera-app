/// Centralized endpoint paths for the authentication feature.
/// All paths are relative (no leading slash, no version prefix).
class AuthEndpoints {
  const AuthEndpoints._();

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String registerVerify = 'auth/register/verify';
  static const String verifyLogin = 'auth/login/verify';
  static const String logout = 'auth/logout';
  static const String changePassword = 'auth/password/change';
  static const String resetPassword = 'auth/password/reset';
  static const String resetPasswordConfirm = 'auth/password/reset-confirm';
  static const String refresh = 'auth/refresh';
  static const String telegramRequestLink = 'auth/telegram/request-link';
  static const String telegramStatus = 'auth/telegram/status';
}
