import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/domain/services/auth_token_provider.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/usecases/change_password.dart';
import 'package:votera/features/authentication/domain/usecases/confirm_reset_password.dart';
import 'package:votera/features/authentication/domain/usecases/get_telegram_status.dart';
import 'package:votera/features/authentication/domain/usecases/login_user.dart';
import 'package:votera/features/authentication/domain/usecases/logout_user.dart';
import 'package:votera/features/authentication/domain/usecases/register_user.dart';
import 'package:votera/features/authentication/domain/usecases/request_telegram_link.dart';
import 'package:votera/features/authentication/domain/usecases/reset_password.dart';
import 'package:votera/features/authentication/domain/usecases/verify_login.dart';

part 'auth_state.dart';

/// Manages authentication state: login, registration, OTP, and logout.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authTokenProvider,
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.verifyLogin,
    required this.changePassword,
    required this.resetPassword,
    required this.confirmResetPassword,
    required this.requestTelegramLink,
    required this.getTelegramStatus,
  }) : super(AuthInitial());

  final AuthTokenProvider authTokenProvider;
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final VerifyLogin verifyLogin;
  final ChangePassword changePassword;
  final ResetPassword resetPassword;
  final ConfirmResetPassword confirmResetPassword;
  final RequestTelegramLink requestTelegramLink;
  final GetTelegramStatus getTelegramStatus;

  // Active polling timer — cancelled on cubit close or successful auth.
  Timer? _pollTimer;

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  /// Checks for saved tokens and restores authenticated state on app startup.
  Future<void> checkAuthStatus() async {
    final isAuthenticated = await authTokenProvider.isAuthenticated();
    if (isAuthenticated) {
      emit(const AuthAuthenticated());
    }
  }

  Future<void> login({
    required String identifier,
    required String secret,
  }) async {
    emit(AuthLoading());
    final result = await loginUser(
      LoginParams(identifier: identifier, secret: secret),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await registerUser(
      RegisterParams(
        fullName: fullName,
        identifier: identifier,
        password: password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    emit(AuthLoading());
    final result = await verifyLogin(
      VerifyLoginParams(identifier: identifier, code: code),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await logoutUser(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthInitial()),
    );
  }

  Future<void> requestChangePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await changePassword(
      ChangePasswordParams(
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordChanged()),
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    emit(AuthLoading());
    final result = await resetPassword(ResetPasswordParams(email: email));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await confirmResetPassword(
      ConfirmResetPasswordParams(token: token, newPassword: newPassword),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetConfirmed()),
    );
  }

  /// Requests a Telegram deep link from the backend, emits the link so the
  /// widget can open Telegram, then starts polling the status endpoint.
  Future<void> loginWithTelegram() async {
    _pollTimer?.cancel();
    emit(AuthLoading());

    final linkResult = await requestTelegramLink(NoParams());
    linkResult.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (data) {
        emit(AuthTelegramAwaitingUser(link: data.link, token: data.token));
        _startPolling(data.token);
      },
    );
  }

  void _startPolling(String token) {
    var attempts = 0;
    // Allow up to 5 minutes (150 polls at 2-second intervals) before giving up.
    const maxAttempts = 150;

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;
      if (attempts >= maxAttempts) {
        timer.cancel();
        emit(const AuthError(
            message: 'Telegram login timed out. Please try again.'));
        return;
      }

      final result =
          await getTelegramStatus(TelegramStatusParams(token: token));
      result.fold(
        // Silently ignore transient network errors (e.g. 502) while polling.
        (_) {},
        (status) {
          if (status.isComplete) {
            timer.cancel();
            emit(const AuthAuthenticated(fromTelegram: true));
          } else if (status.isExpired) {
            timer.cancel();
            emit(const AuthError(
              message: 'Telegram login session expired. Please try again.',
            ));
          }
        },
      );
    });
  }
}
