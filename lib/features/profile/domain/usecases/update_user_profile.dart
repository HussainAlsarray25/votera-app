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
    return repository.updateUserProfile(
      name: params.name,
      email: params.email,
      phone: params.phone,
    );
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({this.name, this.email, this.phone});

  final String? name;
  final String? email;
  final String? phone;

  @override
  List<Object?> get props => [name, email, phone];
}
