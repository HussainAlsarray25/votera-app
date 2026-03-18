import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/authentication/data/datasources/remote/auth_remote_data_source.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.tokenService,
  });

  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final TokenService tokenService;

  @override
  Future<Either<Failure, void>> login({
    required String identifier,
    required String secret,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.login(
        identifier: identifier,
        secret: secret,
      );
      await _saveTokensFromResponse(result);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );
      await _saveTokensFromResponse(result);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyLogin({
    required String identifier,
    required String code,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.verifyLogin(
        identifier: identifier,
        code: code,
      );
      await _saveTokensFromResponse(result);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await tokenService.clearTokens();
      return const Right(null);
    } on Exception catch (_) {
      // Always clear tokens locally even if the server call fails.
      await tokenService.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.confirmResetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Extracts tokens from the identity-module wrapped response
  /// and persists them locally.
  Future<void> _saveTokensFromResponse(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>?;
    final accessToken = data?['access_token'] as String?;
    final refreshToken = data?['refresh_token'] as String?;
    if (accessToken != null) {
      await tokenService.saveAccessToken(accessToken);
    }
    if (refreshToken != null) {
      await tokenService.saveRefreshToken(refreshToken);
    }
  }
}
