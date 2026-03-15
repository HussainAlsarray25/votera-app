import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfile extends UseCase<UserProfile, NoParams> {
  GetUserProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) {
    return repository.getUserProfile();
  }
}
