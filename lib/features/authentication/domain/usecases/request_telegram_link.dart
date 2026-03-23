import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/entities/telegram_auth.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class RequestTelegramLink extends UseCase<TelegramLinkData, NoParams> {
  RequestTelegramLink(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, TelegramLinkData>> call(NoParams _) =>
      repository.requestTelegramLink();
}
