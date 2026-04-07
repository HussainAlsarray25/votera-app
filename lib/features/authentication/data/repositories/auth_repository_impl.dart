import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/authentication/data/datasources/remote/auth_remote_data_source.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';
import 'package:votera/features/authentication/domain/entities/telegram_auth.dart';
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
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      // The API returns 202 Accepted with no tokens — OTP verification is required
      // before tokens are issued. Do not attempt to save tokens here.
      await remoteDataSource.register(
        fullName: fullName,
        identifier: identifier,
        password: password,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> verifyRegistration({
    required String identifier,
    required String code,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.verifyRegistration(
        identifier: identifier,
        code: code,
      );
      await _saveTokensFromResponse(result);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
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
      return Left(ServerFailure(message: extractErrorMessage(e)));
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
      return Left(ServerFailure(message: extractErrorMessage(e)));
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
      return Left(ServerFailure(message: extractErrorMessage(e)));
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
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, TelegramLinkData>> requestTelegramLink() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.requestTelegramLink();
      final data = result['data'] as Map<String, dynamic>;
      return Right(TelegramLinkData(
        token: data['token'] as String,
        link: data['link'] as String,
      ));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, TelegramAuthStatus>> getTelegramStatus(
      String token) async {
    // No connectivity pre-check here. On a slow (but connected) network the
    // check itself can return false, causing every poll to be silently skipped
    // while the backend has already issued tokens. The cubit handles Left
    // results gracefully (ignores and retries on the next tick).
    try {
      final result = await remoteDataSource.getTelegramStatus(token);
      final data = result['data'] as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'pending';
      if (status == 'success') {
        // Persist tokens — same helper used by regular login.
        await _saveTokensFromResponse(result);
        return const Right(TelegramAuthStatus(isComplete: true));
      }
      if (status == 'expired') {
        return const Right(TelegramAuthStatus(isComplete: false, isExpired: true));
      }
      return const Right(TelegramAuthStatus(isComplete: false));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> savePendingTelegramSession(
      String token, String link) async {
    try {
      await tokenService.savePendingTelegramSession(token, link);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, PendingTelegramSession?>>
      loadPendingTelegramSession() async {
    try {
      final session = await tokenService.loadPendingTelegramSession();
      return Right(session);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> clearPendingTelegramSession() async {
    try {
      await tokenService.clearPendingTelegramSession();
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
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
