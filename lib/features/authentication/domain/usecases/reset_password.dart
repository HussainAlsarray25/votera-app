import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class ResetPassword extends UseCase<void, ResetPasswordParams> {
  ResetPassword(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(email: params.email);
  }
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
