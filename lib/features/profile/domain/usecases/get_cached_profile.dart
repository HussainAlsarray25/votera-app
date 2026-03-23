import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

/// Returns the profile stored in local cache, or null if no cache exists.
/// Local reads are always successful — errors are not possible here.
class GetCachedProfile extends UseCase<UserProfile?, NoParams> {
  GetCachedProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfile?>> call(NoParams params) async {
    return Right(await repository.getCachedProfile());
  }
}
