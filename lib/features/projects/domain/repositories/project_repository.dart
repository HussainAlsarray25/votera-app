import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/entities/upload_url_entity.dart';

abstract class ProjectRepository {
  /// Fetches a paginated list of projects for the given event.
  Future<Either<Failure, PaginatedResponse<ProjectEntity>>> getProjects({
    required String eventId,
    required int page,
    required int size,
  });

  /// Fetches a single project by its ID within an event.
  Future<Either<Failure, ProjectEntity>> getProjectById({
    required String eventId,
    required String projectId,
  });

  /// Creates a new project submission under the given event.
  Future<Either<Failure, ProjectEntity>> submitProject({
    required String eventId,
    required String title,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
  });

  /// Updates an existing project's details.
  Future<Either<Failure, ProjectEntity>> updateProject({
    required String eventId,
    required String projectId,
    String? title,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
  });

  /// Requests a pre-signed upload URL for attaching media to a project.
  Future<Either<Failure, UploadUrlEntity>> getUploadUrl({
    required String eventId,
    required String projectId,
    required String fileName,
    String? fileType,
  });

  /// Looks up a project by its QR barcode token.
  Future<Either<Failure, ProjectEntity>> scanProject(String token);

  /// Tags a project with a category.
  Future<Either<Failure, void>> addProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  });

  /// Removes a category tag from a project.
  Future<Either<Failure, void>> removeProjectCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  });

  /// Transitions a project from draft to submitted status.
  Future<Either<Failure, ProjectEntity>> finalizeProject({
    required String eventId,
    required String projectId,
  });

  /// Cancels a submitted project.
  Future<Either<Failure, ProjectEntity>> cancelProject({
    required String eventId,
    required String projectId,
  });

  /// Deletes a media attachment from a project.
  Future<Either<Failure, void>> deleteProjectMedia({
    required String eventId,
    required String projectId,
    required String mediaId,
  });

  /// Fetches the authenticated user's own project for the given event.
  /// Returns a [NotFoundFailure] when the user has no project in this event.
  Future<Either<Failure, ProjectEntity>> getMyProject({
    required String eventId,
  });
}
