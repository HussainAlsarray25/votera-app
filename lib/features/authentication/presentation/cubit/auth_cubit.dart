import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/usecases/change_password.dart';
import 'package:votera/features/authentication/domain/usecases/confirm_reset_password.dart';
import 'package:votera/features/authentication/domain/usecases/login_user.dart';
import 'package:votera/features/authentication/domain/usecases/logout_user.dart';
import 'package:votera/features/authentication/domain/usecases/register_user.dart';
import 'package:votera/features/authentication/domain/usecases/reset_password.dart';
import 'package:votera/features/authentication/domain/usecases/verify_login.dart';

part 'auth_state.dart';

/// Manages authentication state: login, registration, OTP, and logout.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.verifyLogin,
    required this.changePassword,
    required this.resetPassword,
    required this.confirmResetPassword,
  }) : super(AuthInitial());

  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final VerifyLogin verifyLogin;
  final ChangePassword changePassword;
  final ResetPassword resetPassword;
  final ConfirmResetPassword confirmResetPassword;

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
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(AuthLoading());
    final result = await registerUser(
      RegisterParams(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
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
}
