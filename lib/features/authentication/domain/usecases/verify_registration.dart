import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class VerifyRegistration extends UseCase<void, VerifyRegistrationParams> {
  VerifyRegistration(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(VerifyRegistrationParams params) {
    return repository.verifyRegistration(
      identifier: params.identifier,
      code: params.code,
    );
  }
}

class VerifyRegistrationParams extends Equatable {
  const VerifyRegistrationParams({
    required this.identifier,
    required this.code,
  });

  final String identifier;
  final String code;

  @override
  List<Object?> get props => [identifier, code];
}
