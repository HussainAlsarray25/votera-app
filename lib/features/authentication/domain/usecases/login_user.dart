import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class LoginUser extends UseCase<void, LoginParams> {
  LoginUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(LoginParams params) {
    return repository.login(
      identifier: params.identifier,
      secret: params.secret,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.identifier, required this.secret});

  final String identifier;
  final String secret;

  @override
  List<Object?> get props => [identifier, secret];
}
