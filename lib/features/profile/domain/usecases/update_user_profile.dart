import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfile extends UseCase<UserProfile, UpdateProfileParams> {
  UpdateUserProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) {
    return repository.updateUserProfile(fullName: params.fullName);
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({this.fullName});

  final String? fullName;

  @override
  List<Object?> get props => [fullName];
}
