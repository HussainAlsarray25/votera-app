import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/entities/telegram_auth.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class LoadPendingTelegramSession
    extends UseCase<PendingTelegramSession?, NoParams> {
  LoadPendingTelegramSession(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, PendingTelegramSession?>> call(NoParams _) =>
      repository.loadPendingTelegramSession();
}
