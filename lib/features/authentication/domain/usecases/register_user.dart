import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUser extends UseCase<void, RegisterParams> {
  RegisterUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.register(
      fullName: params.fullName,
      identifier: params.identifier,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.fullName,
    required this.identifier,
    required this.password,
  });

  final String fullName;
  final String identifier;
  final String password;

  @override
  List<Object?> get props => [fullName, identifier, password];
}
