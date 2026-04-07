import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/projects/domain/entities/media_upload_response_entity.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  /// Fetches a paginated list of projects for the given event.
  /// Pass [categoryId] to filter results to a single category.
  Future<Either<Failure, PaginatedResponse<ProjectEntity>>> getProjects({
    required String eventId,
    required int page,
    required int size,
    String? title,
    String? categoryId,
  });

  /// Fetches a single project by its ID within an event.
  Future<Either<Failure, ProjectEntity>> getProjectById({
    required String eventId,
    required String projectId,
  });

  /// Creates a new project submission under the given event.
  /// Pass [teamId] when the user belongs to multiple teams and must choose one.
  /// If omitted the backend uses the user's first team.
  /// Pass [categoryIds] to tag the project with up to 3 categories on creation.
  Future<Either<Failure, ProjectEntity>> submitProject({
    required String eventId,
    required String title,
    String? teamId,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
    List<String>? categoryIds,
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

  /// Fetches the authenticated user's own project for the given event.
  /// Pass [teamId] when the user belongs to multiple teams.
  /// Returns a [ServerFailure] with statusCode 404 when the user has no
  /// project in this event.
  Future<Either<Failure, ProjectEntity>> getMyProject({
    required String eventId,
    String? teamId,
  });

  /// Uploads raw image bytes as the project cover.
  /// If a cover already exists it is automatically replaced.
  Future<Either<Failure, MediaUploadResponseEntity>> uploadCover({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  });

  /// Deletes the project cover image.
  Future<Either<Failure, void>> deleteCover({
    required String eventId,
    required String projectId,
  });

  /// Uploads raw image bytes as an extra image (max 6 per project).
  Future<Either<Failure, MediaUploadResponseEntity>> uploadExtraImage({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  });

  /// Deletes a specific extra image by its ID.
  Future<Either<Failure, void>> deleteExtraImage({
    required String eventId,
    required String projectId,
    required String imageId,
  });

  /// Permanently deletes a draft project.
  Future<Either<Failure, void>> deleteProject({
    required String eventId,
    required String projectId,
  });
}
