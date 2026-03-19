import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/projects/data/datasources/remote/project_remote_data_source.dart';
import 'package:votera/features/projects/data/repositories/project_repository_impl.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';
import 'package:votera/features/projects/domain/usecases/add_project_category.dart';
import 'package:votera/features/projects/domain/usecases/cancel_project.dart';
import 'package:votera/features/projects/domain/usecases/delete_project_media.dart';
import 'package:votera/features/projects/domain/usecases/finalize_project.dart';
import 'package:votera/features/projects/domain/usecases/get_project_by_id.dart';
import 'package:votera/features/projects/domain/usecases/get_projects.dart';
import 'package:votera/features/projects/domain/usecases/get_upload_url.dart';
import 'package:votera/features/projects/domain/usecases/remove_project_category.dart';
import 'package:votera/features/projects/domain/usecases/scan_project.dart';
import 'package:votera/features/projects/domain/usecases/submit_project.dart';
import 'package:votera/features/projects/domain/usecases/update_project.dart';
import 'package:votera/features/projects/presentation/cubit/projects_cubit.dart';

void initProjectsFeature(GetIt sl) {
  sl
    // Cubits -- registered as factory so each page gets a fresh instance.
    ..registerFactory<ProjectsCubit>(
      () => ProjectsCubit(
        getProjects: sl<GetProjects>(),
        getProjectById: sl<GetProjectById>(),
        submitProject: sl<SubmitProject>(),
        updateProject: sl<UpdateProject>(),
        getUploadUrl: sl<GetUploadUrl>(),
        scanProject: sl<ScanProject>(),
        addProjectCategory: sl<AddProjectCategory>(),
        removeProjectCategory: sl<RemoveProjectCategory>(),
        finalizeProject: sl<FinalizeProject>(),
        cancelProject: sl<CancelProject>(),
        deleteProjectMedia: sl<DeleteProjectMedia>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetProjects>(
      () => GetProjects(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<GetProjectById>(
      () => GetProjectById(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<SubmitProject>(
      () => SubmitProject(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<UpdateProject>(
      () => UpdateProject(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<GetUploadUrl>(
      () => GetUploadUrl(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<ScanProject>(
      () => ScanProject(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<AddProjectCategory>(
      () => AddProjectCategory(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<RemoveProjectCategory>(
      () => RemoveProjectCategory(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<FinalizeProject>(
      () => FinalizeProject(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<CancelProject>(
      () => CancelProject(sl<ProjectRepository>()),
    )
    ..registerLazySingleton<DeleteProjectMedia>(
      () => DeleteProjectMedia(sl<ProjectRepository>()),
    )
    // Repositories
    ..registerLazySingleton<ProjectRepository>(
      () => ProjectRepositoryImpl(
        remoteDataSource: sl<ProjectRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}
