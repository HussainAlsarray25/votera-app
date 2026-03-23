import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/authentication/domain/entities/telegram_auth.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login({
    required String identifier,
    required String secret,
  });

  Future<Either<Failure, void>> register({
    required String fullName,
    required String identifier,
    required String password,
  });

  Future<Either<Failure, void>> verifyLogin({
    required String identifier,
    required String code,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  Future<Either<Failure, void>> confirmResetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, TelegramLinkData>> requestTelegramLink();

  Future<Either<Failure, TelegramAuthStatus>> getTelegramStatus(String token);
}
