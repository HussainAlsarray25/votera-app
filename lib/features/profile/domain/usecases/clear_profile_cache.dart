import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

/// Clears the locally cached profile. Called on logout so the next
/// user session starts with a fresh fetch.
class ClearProfileCache extends UseCase<void, NoParams> {
  ClearProfileCache(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    await repository.clearCache();
    return const Right(null);
  }
}
