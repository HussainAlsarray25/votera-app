import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/projects/domain/entities/media_upload_response_entity.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/usecases/add_project_category.dart';
import 'package:votera/features/projects/domain/usecases/cancel_project.dart';
import 'package:votera/features/projects/domain/usecases/delete_project.dart';
import 'package:votera/features/projects/domain/usecases/delete_project_cover.dart';
import 'package:votera/features/projects/domain/usecases/delete_project_extra_image.dart';
import 'package:votera/features/projects/domain/usecases/finalize_project.dart';
import 'package:votera/features/projects/domain/usecases/get_my_project.dart';
import 'package:votera/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:votera/features/projects/domain/usecases/get_projects.dart';
import 'package:votera/features/projects/domain/usecases/remove_project_category.dart';
import 'package:votera/features/projects/domain/usecases/scan_project.dart';
import 'package:votera/features/projects/domain/usecases/submit_project.dart';
import 'package:votera/features/projects/domain/usecases/update_project.dart';
import 'package:votera/features/projects/domain/usecases/upload_project_cover.dart';
import 'package:votera/features/projects/domain/usecases/upload_project_extra_image.dart';

part 'projects_state.dart';

/// Manages all state transitions for the projects feature:
/// listing, viewing, creating, updating, and managing cover and extra images.
class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required this.getProjects,
    required this.getProjectById,
    required this.getMyProject,
    required this.submitProject,
    required this.updateProject,
    required this.uploadProjectCover,
    required this.deleteProjectCover,
    required this.uploadProjectExtraImage,
    required this.deleteProjectExtraImage,
    required this.scanProject,
    required this.addProjectCategory,
    required this.removeProjectCategory,
    required this.finalizeProject,
    required this.cancelProject,
    required this.deleteProject,
  }) : super(const ProjectsInitial());

  final GetProjects getProjects;
  final GetProjectById getProjectById;
  final GetMyProject getMyProject;
  final SubmitProject submitProject;
  final UpdateProject updateProject;
  final UploadProjectCover uploadProjectCover;
  final DeleteProjectCover deleteProjectCover;
  final UploadProjectExtraImage uploadProjectExtraImage;
  final DeleteProjectExtraImage deleteProjectExtraImage;
  final ScanProject scanProject;
  final AddProjectCategory addProjectCategory;
  final RemoveProjectCategory removeProjectCategory;
  final FinalizeProject finalizeProject;
  final CancelProject cancelProject;
  final DeleteProject deleteProject;

  // Prevents concurrent pagination requests.
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // Guard against emitting after the cubit is disposed. This can happen when an
  // async request is in flight and the user navigates away before it resolves.
  @override
  void emit(ProjectsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> loadProjects({
    required String eventId,
    int page = 1,
    int size = 20,
    String? title,
    String? categoryId,
  }) async {
    emit(const ProjectsLoading());
    final result = await getProjects(
      GetProjectsParams(
        eventId: eventId,
        page: page,
        size: size,
        title: title,
        categoryId: categoryId,
      ),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (paginated) => emit(
        ProjectsLoaded(
          projects: paginated.items,
          hasNextPage: paginated.hasNextPage,
          currentPage: paginated.page,
          total: paginated.total,
        ),
      ),
    );
  }

  /// Appends the next page of projects to the already-loaded list.
  /// No-ops if a fetch is already in flight or there is no next page.
  Future<void> loadMoreProjects({
    required String eventId,
    required List<ProjectEntity> existingProjects,
    required int nextPage,
    int size = 20,
    String? title,
    String? categoryId,
  }) async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    final result = await getProjects(
      GetProjectsParams(
        eventId: eventId,
        page: nextPage,
        size: size,
        title: title,
        categoryId: categoryId,
      ),
    );
    _isLoadingMore = false;
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (paginated) => emit(
        ProjectsLoaded(
          projects: [...existingProjects, ...paginated.items],
          hasNextPage: paginated.hasNextPage,
          currentPage: paginated.page,
          total: paginated.total,
        ),
      ),
    );
  }

  Future<void> loadProjectById({
    required String eventId,
    required String projectId,
  }) async {
    emit(const ProjectsLoading());
    final result = await getProjectById(
      GetProjectByIdParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (project) => emit(ProjectDetailLoaded(project: project)),
    );
  }

  /// Fetches the current user's project for the given event.
  /// Emits [MyProjectNotFound] when the user has no project (404 response).
  Future<void> loadMyProject({
    required String eventId,
    String? teamId,
  }) async {
    emit(const ProjectsLoading());
    await _fetchMyProject(eventId: eventId, teamId: teamId);
  }

  /// Reloads the current user's project without emitting [ProjectsLoading].
  /// Use this after image/category operations to refresh data silently,
  /// so the UI does not flash a full-page spinner.
  Future<void> reloadMyProjectSilent({
    required String eventId,
    String? teamId,
  }) async {
    await _fetchMyProject(eventId: eventId, teamId: teamId);
  }

  /// Shared fetch logic used by [loadMyProject] and [reloadMyProjectSilent].
  Future<void> _fetchMyProject({
    required String eventId,
    String? teamId,
  }) async {
    final result = await getMyProject(
      GetMyProjectParams(eventId: eventId, teamId: teamId),
    );
    result.fold(
      (failure) {
        // A 404 means the user simply has not submitted a project yet.
        // Treat it as a "no project" state rather than an error.
        final is404 = failure is ServerFailure && failure.statusCode == 404;
        if (is404) {
          emit(const MyProjectNotFound());
        } else {
          emit(ProjectsError(message: failure.message));
        }
      },
      (project) => emit(MyProjectLoaded(project: project)),
    );
  }

  Future<void> createProject({
    required String eventId,
    required String title,
    String? teamId,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
    List<String>? categoryIds,
  }) async {
    emit(const ProjectsLoading());
    final result = await submitProject(
      SubmitProjectParams(
        eventId: eventId,
        title: title,
        teamId: teamId,
        description: description,
        repoUrl: repoUrl,
        demoUrl: demoUrl,
        techStack: techStack,
        categoryIds: categoryIds,
      ),
    );
    result.fold(
      // Creation rejected by the backend — preserve the form so the user
      // can see the error and correct their input.
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (project) => emit(ProjectSaved(project: project)),
    );
  }

  Future<void> editProject({
    required String eventId,
    required String projectId,
    String? title,
    String? description,
    String? repoUrl,
    String? demoUrl,
    String? techStack,
  }) async {
    emit(const ProjectsLoading());
    final result = await updateProject(
      UpdateProjectParams(
        eventId: eventId,
        projectId: projectId,
        title: title,
        description: description,
        repoUrl: repoUrl,
        demoUrl: demoUrl,
        techStack: techStack,
      ),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (project) => emit(ProjectSaved(project: project)),
    );
  }

  /// Looks up a project by its QR barcode token.
  Future<void> scan(String token) async {
    emit(const ProjectsLoading());
    final result = await scanProject(ScanProjectParams(token: token));
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (project) => emit(ProjectDetailLoaded(project: project)),
    );
  }

  /// Tags a project with a category.
  /// Does not emit ProjectsLoading — category add/remove is a fast silent
  /// operation and a full-page spinner would disrupt the picker UI.
  Future<void> addCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    final result = await addProjectCategory(
      AddProjectCategoryParams(
        eventId: eventId,
        projectId: projectId,
        categoryId: categoryId,
      ),
    );
    result.fold(
      // Use ProjectActionFailed so the UI shows a snackbar rather than
      // replacing the whole view with an error screen (e.g. 409 conflict).
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (_) => emit(const ProjectCategoryUpdated()),
    );
  }

  /// Removes a category tag from a project.
  /// Does not emit ProjectsLoading — same reasoning as addCategory.
  Future<void> removeCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    final result = await removeProjectCategory(
      RemoveProjectCategoryParams(
        eventId: eventId,
        projectId: projectId,
        categoryId: categoryId,
      ),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (_) => emit(const ProjectCategoryUpdated()),
    );
  }

  /// Transitions a project from draft to submitted.
  Future<void> finalize({
    required String eventId,
    required String projectId,
  }) async {
    emit(const ProjectsLoading());
    final result = await finalizeProject(
      FinalizeProjectParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      // Finalize rejected (e.g. already submitted) — project still exists,
      // so preserve the project view and surface the error as a snackbar.
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (project) => emit(ProjectSaved(project: project)),
    );
  }

  /// Cancels a submitted project.
  Future<void> cancel({
    required String eventId,
    required String projectId,
  }) async {
    emit(const ProjectsLoading());
    final result = await cancelProject(
      CancelProjectParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (project) => emit(ProjectSaved(project: project)),
    );
  }

  /// Permanently deletes a draft project.
  Future<void> delete({
    required String eventId,
    required String projectId,
  }) async {
    emit(const ProjectsLoading());
    final result = await deleteProject(
      DeleteProjectParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (_) => emit(const ProjectDeleted()),
    );
  }

  /// Uploads raw image bytes as the project cover.
  /// Does not emit [ProjectsLoading] — the caller uses a local loading state
  /// so the rest of the project view stays visible during the upload.
  Future<void> uploadCover({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  }) async {
    final result = await uploadProjectCover(
      UploadProjectCoverParams(
        eventId: eventId,
        projectId: projectId,
        bytes: bytes,
        contentType: contentType,
      ),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (response) => emit(ProjectCoverUploaded(uploadResponse: response)),
    );
  }

  /// Deletes the project cover image.
  /// Does not emit [ProjectsLoading] — same reasoning as [uploadCover].
  Future<void> removeCover({
    required String eventId,
    required String projectId,
  }) async {
    final result = await deleteProjectCover(
      DeleteProjectCoverParams(eventId: eventId, projectId: projectId),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (_) => emit(const ProjectCoverDeleted()),
    );
  }

  /// Uploads raw image bytes as an extra project image (max 6 per project).
  /// Does not emit [ProjectsLoading] — same reasoning as [uploadCover].
  Future<void> uploadExtraImage({
    required String eventId,
    required String projectId,
    required List<int> bytes,
    required String contentType,
  }) async {
    final result = await uploadProjectExtraImage(
      UploadProjectExtraImageParams(
        eventId: eventId,
        projectId: projectId,
        bytes: bytes,
        contentType: contentType,
      ),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (response) => emit(ProjectExtraImageUploaded(uploadResponse: response)),
    );
  }

  /// Deletes a specific extra image by its ID.
  /// Does not emit [ProjectsLoading] — same reasoning as [uploadCover].
  Future<void> removeExtraImage({
    required String eventId,
    required String projectId,
    required String imageId,
  }) async {
    final result = await deleteProjectExtraImage(
      DeleteProjectExtraImageParams(
        eventId: eventId,
        projectId: projectId,
        imageId: imageId,
      ),
    );
    result.fold(
      (failure) => emit(ProjectActionFailed(message: failure.message)),
      (_) => emit(ProjectExtraImageDeleted(imageId: imageId)),
    );
  }
}
