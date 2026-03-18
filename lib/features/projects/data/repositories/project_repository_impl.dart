import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/projects/data/datasources/remote/project_remote_data_source.dart';
import 'package:votera/features/projects/data/models/project_model.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/entities/upload_url_entity.dart';
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remoteDataSource.getProjects(
        eventId: eventId,
        page: page,
        size: size,
      );
      final paginated = PaginatedResponse<ProjectEntity>.fromJson(
        json,
        ProjectModel.fromJson,
      );
      return Right(paginated);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> submitProject({
    required String eventId,
    required String title,
    String? description,
    String? repoUrl,
    String? demoUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final project = await remoteDataSource.submitProject(
        eventId: eventId,
        title: title,
        description: description,
        repoUrl: repoUrl,
        demoUrl: demoUrl,
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      );
      return Right(project);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UploadUrlEntity>> getUploadUrl({
    required String eventId,
    required String projectId,
    required String fileName,
    String? fileType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final uploadUrl = await remoteDataSource.getUploadUrl(
        eventId: eventId,
        projectId: projectId,
        fileName: fileName,
        fileType: fileType,
      );
      return Right(uploadUrl);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
