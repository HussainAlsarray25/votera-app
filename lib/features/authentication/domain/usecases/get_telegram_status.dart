import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/entities/telegram_auth.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class TelegramStatusParams extends Equatable {
  const TelegramStatusParams({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

class GetTelegramStatus extends UseCase<TelegramAuthStatus, TelegramStatusParams> {
  GetTelegramStatus(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, TelegramAuthStatus>> call(TelegramStatusParams params) =>
      repository.getTelegramStatus(params.token);
}
