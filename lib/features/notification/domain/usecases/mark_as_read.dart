import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class MarkAsReadParams extends Equatable {
  const MarkAsReadParams({required this.id});

  final String id;

  @override
  List<Object> get props => [id];
}

class MarkAsRead extends UseCase<void, MarkAsReadParams> {
  MarkAsRead(this.repository);

  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return repository.markAsRead(params.id);
  }
}
