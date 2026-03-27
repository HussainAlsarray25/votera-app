import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class UploadTeamImageParams extends Equatable {
  const UploadTeamImageParams({
    required this.teamId,
    required this.fileName,
    required this.bytes,
  });

  final String teamId;
  final String fileName;

  // In-memory file bytes — obtained from file_picker with withData: true,
  // which works on mobile, desktop, and web without using dart:io.
  final List<int> bytes;

  @override
  List<Object> get props => [teamId, fileName, bytes];
}

class UploadTeamImage extends UseCase<void, UploadTeamImageParams> {
  UploadTeamImage(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(UploadTeamImageParams params) {
    return repository.uploadTeamImage(
      teamId: params.teamId,
      fileName: params.fileName,
      bytes: params.bytes,
    );
  }
}
