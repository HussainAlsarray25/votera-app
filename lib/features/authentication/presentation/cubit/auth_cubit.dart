import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/entities/user_entity.dart';
import 'package:votera/features/authentication/domain/usecases/login_user.dart';
import 'package:votera/features/authentication/domain/usecases/logout_user.dart';
import 'package:votera/features/authentication/domain/usecases/register_user.dart';

part 'auth_state.dart';

/// Manages authentication state: login, registration, and logout.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
  }) : super(AuthInitial());

  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await loginUser(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await registerUser(
      RegisterParams(
        name: name,
        email: email,
        password: password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
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
}
