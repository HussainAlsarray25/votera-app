part of 'projects_cubit.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

/// Emitted when a paginated list of projects has been loaded successfully.
class ProjectsLoaded extends ProjectsState {
  const ProjectsLoaded({
    required this.projects,
    required this.hasNextPage,
    required this.currentPage,
  });

  final List<ProjectEntity> projects;

  /// Whether there are additional pages to load.
  final bool hasNextPage;

  final int currentPage;

  @override
  List<Object?> get props => [projects, hasNextPage, currentPage];
}

/// Emitted when a single project has been fetched or created/updated.
class ProjectDetailLoaded extends ProjectsState {
  const ProjectDetailLoaded({required this.project});

  final ProjectEntity project;

  @override
  List<Object?> get props => [project];
}

/// Emitted after a project is submitted or updated successfully.
class ProjectSaved extends ProjectsState {
  const ProjectSaved({required this.project});

  final ProjectEntity project;

  @override
  List<Object?> get props => [project];
}

/// Emitted when the upload URL has been retrieved successfully.
class UploadUrlReady extends ProjectsState {
  const UploadUrlReady({required this.uploadUrl});

  final UploadUrlEntity uploadUrl;

  @override
  List<Object?> get props => [uploadUrl];
}

/// Emitted after a project category is added or removed.
class ProjectCategoryUpdated extends ProjectsState {
  const ProjectCategoryUpdated();
}

/// Emitted after a media attachment is deleted from a project.
class ProjectMediaDeleted extends ProjectsState {
  const ProjectMediaDeleted();
}

class ProjectsError extends ProjectsState {
  const ProjectsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
