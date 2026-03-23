import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class ConfirmResetPassword extends UseCase<void, ConfirmResetPasswordParams> {
  ConfirmResetPassword(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(ConfirmResetPasswordParams params) {
    return repository.confirmResetPassword(
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}

class ConfirmResetPasswordParams extends Equatable {
  const ConfirmResetPasswordParams({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;

  @override
  List<Object?> get props => [token, newPassword];
}
