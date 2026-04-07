import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/team_image_upload_url_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class GetTeamImageUploadUrlParams extends Equatable {
  const GetTeamImageUploadUrlParams({
    required this.teamId,
    required this.fileName,
  });

  final String teamId;
  final String fileName;

  @override
  List<Object> get props => [teamId, fileName];
}

class GetTeamImageUploadUrl
    extends UseCase<TeamImageUploadUrlEntity, GetTeamImageUploadUrlParams> {
  GetTeamImageUploadUrl(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, TeamImageUploadUrlEntity>> call(
    GetTeamImageUploadUrlParams params,
  ) {
    return repository.getTeamImageUploadUrl(
      teamId: params.teamId,
      fileName: params.fileName,
    );
  }
}
