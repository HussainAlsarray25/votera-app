import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class ScanProjectParams extends Equatable {
  const ScanProjectParams({required this.token});

  final String token;

  @override
  List<Object> get props => [token];
}

/// Looks up a project by its QR barcode token.
class ScanProject extends UseCase<ProjectEntity, ScanProjectParams> {
  ScanProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(ScanProjectParams params) {
    return repository.scanProject(params.token);
  }
}
