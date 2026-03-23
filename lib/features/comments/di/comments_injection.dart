import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/comments/data/datasources/remote/comment_remote_data_source.dart';
import 'package:votera/features/comments/data/repositories/comment_repository_impl.dart';
import 'package:votera/features/comments/domain/repositories/comment_repository.dart';
import 'package:votera/features/comments/domain/usecases/delete_comment.dart';
import 'package:votera/features/comments/domain/usecases/get_comments.dart';
import 'package:votera/features/comments/domain/usecases/post_comment.dart';
import 'package:votera/features/comments/domain/usecases/update_comment.dart';
import 'package:votera/features/comments/presentation/cubit/comments_cubit.dart';

/// Registers all dependencies for the comments feature.
/// Call this from the core injection container's [_initFeatures] function.
void initCommentsFeature(GetIt sl) {
  sl
    // Cubits - registered as factory so each screen gets a fresh instance.
    ..registerFactory<CommentsCubit>(
      () => CommentsCubit(
        getComments: sl<GetComments>(),
        postComment: sl<PostComment>(),
        updateComment: sl<UpdateComment>(),
        deleteComment: sl<DeleteComment>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetComments>(
      () => GetComments(sl<CommentRepository>()),
    )
    ..registerLazySingleton<PostComment>(
      () => PostComment(sl<CommentRepository>()),
    )
    ..registerLazySingleton<UpdateComment>(
      () => UpdateComment(sl<CommentRepository>()),
    )
    ..registerLazySingleton<DeleteComment>(
      () => DeleteComment(sl<CommentRepository>()),
    )
    // Repositories
    ..registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(
        remote: sl<CommentRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<CommentRemoteDataSource>(
      () => CommentRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}
