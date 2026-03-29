import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/projects/data/datasources/remote/project_remote_data_source.dart';
import 'package:votera/features/projects/data/models/project_model.dart';
import 'package:votera/features/projects/domain/entities/media_upload_response_entity.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ProjectRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<ProjectEntity>>> getProjects({
    required String eventId,
    required int page,
    required int size,
    String? title,
    String? categoryId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remoteDataSource.getProjects(
        eventId: eventId,
        page: page,
        size: size,
        title: title,
        categoryId: categoryId,
      );
      final paginated = PaginatedResponse<ProjectEntity>.fromJson(
        json,
        ProjectModel.fromJson,
      );
      return Right(paginated);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProjectById({
    required String eventId,
    required String projectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.getProjectById(
        eventId: eventId,
        projectId: projectId,
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> submitProject({
    required String eventId,
    required String title,
    String? teamId,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.submitProject(
        eventId: eventId,
        title: title,
        teamId: teamId,
        description: description,
        repoUrl: repoUrl,
        demoUrl: demoUrl,
        techStack: techStack,
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject({
    required String eventId,
    required String projectId,
    String? title,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.updateProject(
        eventId: eventId,
        projectId: projectId,
        title: title,
        description: description,
        repoUrl: repoUrl,
        demoUrl: demoUrl,
        techStack: techStack,
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> scanProject(String token) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.scanProject(token);
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> addProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.addProjectCategory(
        eventId: eventId,
        projectId: projectId,
        categoryId: categoryId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> removeProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.removeProjectCategory(
        eventId: eventId,
        projectId: projectId,
        categoryId: categoryId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> finalizeProject({
    required String eventId,
    required String projectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.finalizeProject(
        eventId: eventId,
        projectId: projectId,
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> cancelProject({
    required String eventId,
    required String projectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.cancelProject(
        eventId: eventId,
        projectId: projectId,
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getMyProject({
    required String eventId,
    String? teamId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.getMyProject(
        eventId: eventId,
        teamId: teamId,
      );
      return Right(project);
    } on DioException catch (e) {
      // Preserve the HTTP status code so callers (e.g. the cubit) can
      // distinguish a 404 "no project yet" from a real server error.
      return Left(
        ServerFailure(
          message: extractErrorMessage(e),
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, MediaUploadResponseEntity>> uploadCover({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.uploadCover(
        eventId: eventId,
        projectId: projectId,
        bytes: bytes,
        contentType: contentType,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCover({
    required String eventId,
    required String projectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteCover(
        eventId: eventId,
        projectId: projectId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, MediaUploadResponseEntity>> uploadExtraImage({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.uploadExtraImage(
        eventId: eventId,
        projectId: projectId,
        bytes: bytes,
        contentType: contentType,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExtraImage({
    required String eventId,
    required String projectId,
    required String imageId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteExtraImage(
        eventId: eventId,
        projectId: projectId,
        imageId: imageId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}
