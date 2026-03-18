import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/entities/upload_url_entity.dart';
import 'package:votera/features/projects/domain/usecases/add_project_category.dart';
import 'package:votera/features/projects/domain/usecases/finalize_project.dart';
import 'package:votera/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:votera/features/projects/domain/usecases/get_projects.dart';
import 'package:votera/features/projects/domain/usecases/get_upload_url.dart';
import 'package:votera/features/projects/domain/usecases/remove_project_category.dart';
import 'package:votera/features/projects/domain/usecases/scan_project.dart';
import 'package:votera/features/projects/domain/usecases/submit_project.dart';
import 'package:votera/features/projects/domain/usecases/update_project.dart';

part 'projects_state.dart';

/// Manages all state transitions for the projects feature:
/// listing, viewing, creating, updating, and requesting upload URLs.
class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required this.getProjects,
    required this.getProjectById,
    required this.submitProject,
    required this.updateProject,
    required this.getUploadUrl,
    required this.scanProject,
    required this.addProjectCategory,
    required this.removeProjectCategory,
    required this.finalizeProject,
  }) : super(const ProjectsInitial());

  final GetProjects getProjects;
  final GetProjectById getProjectById;
  final SubmitProject submitProject;
  final UpdateProject updateProject;
  final GetUploadUrl getUploadUrl;
  final ScanProject scanProject;
  final AddProjectCategory addProjectCategory;
  final RemoveProjectCategory removeProjectCategory;
  final FinalizeProject finalizeProject;

  Future<void> loadProjects({
    required String eventId,
    int page = 1,
    int size = 20,
  }) async {
    emit(const ProjectsLoading());
    final result = await getProjects(
      GetProjectsParams(eventId: eventId, page: page, size: size),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (paginated) => emit(
        ProjectsLoaded(
          projects: paginated.items,
          hasNextPage: paginated.hasNextPage,
          currentPage: paginated.page,
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

  Future<void> createProject({
    required String eventId,
    required String title,
    String? description,
    String? repoUrl,
    String? demoUrl,
  }) async {
    emit(const ProjectsLoading());
    final result = await submitProject(
      SubmitProjectParams(
        eventId: eventId,
        title: title,
        description: description,
        repoUrl: repoUrl,
        demoUrl: demoUrl,
      ),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
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
      ),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (project) => emit(ProjectSaved(project: project)),
    );
  }

  Future<void> requestUploadUrl({
    required String eventId,
    required String projectId,
    required String fileName,
    String? fileType,
  }) async {
    emit(const ProjectsLoading());
    final result = await getUploadUrl(
      GetUploadUrlParams(
        eventId: eventId,
        projectId: projectId,
        fileName: fileName,
        fileType: fileType,
      ),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (uploadUrl) => emit(UploadUrlReady(uploadUrl: uploadUrl)),
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
  Future<void> addCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    emit(const ProjectsLoading());
    final result = await addProjectCategory(
      AddProjectCategoryParams(
        eventId: eventId,
        projectId: projectId,
        categoryId: categoryId,
      ),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
      (_) => emit(const ProjectCategoryUpdated()),
    );
  }

  /// Removes a category tag from a project.
  Future<void> removeCategory({
    required String eventId,
    required String projectId,
    required String categoryId,
  }) async {
    emit(const ProjectsLoading());
    final result = await removeProjectCategory(
      RemoveProjectCategoryParams(
        eventId: eventId,
        projectId: projectId,
        categoryId: categoryId,
      ),
    );
    result.fold(
      (failure) => emit(ProjectsError(message: failure.message)),
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
      (failure) => emit(ProjectsError(message: failure.message)),
      (project) => emit(ProjectSaved(project: project)),
    );
  }
}
