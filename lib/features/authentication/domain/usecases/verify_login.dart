import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class VerifyLogin extends UseCase<void, VerifyLoginParams> {
  VerifyLogin(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(VerifyLoginParams params) {
    return repository.verifyLogin(
      identifier: params.identifier,
      code: params.code,
    );
  }
}

class VerifyLoginParams extends Equatable {
  const VerifyLoginParams({
    required this.identifier,
    required this.code,
  });

  final String identifier;
  final String code;

  @override
  List<Object?> get props => [identifier, code];
}
