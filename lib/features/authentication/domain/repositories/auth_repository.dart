import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login({
    required String identifier,
    required String secret,
  });

  Future<Either<Failure, void>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
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
}
