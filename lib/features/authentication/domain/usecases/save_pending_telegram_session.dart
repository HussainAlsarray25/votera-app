import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';

class SavePendingTelegramSessionParams extends Equatable {
  const SavePendingTelegramSessionParams({
    required this.token,
    required this.link,
  });

  final String token;
  final String link;

  @override
  List<Object?> get props => [token, link];
}

class SavePendingTelegramSession
    extends UseCase<void, SavePendingTelegramSessionParams> {
  SavePendingTelegramSession(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(
          SavePendingTelegramSessionParams params) =>
      repository.savePendingTelegramSession(params.token, params.link);
}
