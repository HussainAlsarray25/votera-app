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
      username: params.username,
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String username;
  final String email;
  final String password;
  final String displayName;

  @override
  List<Object?> get props => [username, email, password, displayName];
}
