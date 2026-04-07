import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class ClearPendingTelegramSession extends UseCase<void, NoParams> {
  ClearPendingTelegramSession(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams _) =>
      repository.clearPendingTelegramSession();
}
