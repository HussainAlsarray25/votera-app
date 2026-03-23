import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class GetUnreadCount extends UseCase<int, NoParams> {
  GetUnreadCount(this.repository);

  final NotificationRepository repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.getUnreadCount();
  }
}
