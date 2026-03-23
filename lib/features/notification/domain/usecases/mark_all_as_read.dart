import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class MarkAllAsRead extends UseCase<void, NoParams> {
  MarkAllAsRead(this.repository);

  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.markAllAsRead();
  }
}
