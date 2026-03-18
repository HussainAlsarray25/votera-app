import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/domain/repositories/comment_repository.dart';

/// Retrieves a paginated list of comments for a specific project.
/// Callers control pagination so this use case is safe to reuse for
/// both initial loads and subsequent infinite-scroll pages.
class GetComments
    extends UseCase<PaginatedResponse<CommentEntity>, GetCommentsParams> {
  GetComments(this.repository);

  final CommentRepository repository;

  @override
  Future<Either<Failure, PaginatedResponse<CommentEntity>>> call(
    GetCommentsParams params,
  ) {
    return repository.getComments(
      projectId: params.projectId,
      page: params.page,
      size: params.size,
    );
  }
}

/// Parameters for [GetComments].
/// Bundled into a value object so the use-case signature stays stable
/// if extra filter criteria are added later.
class GetCommentsParams extends Equatable {
  const GetCommentsParams({
    required this.projectId,
    required this.page,
    required this.size,
  });

  final String projectId;
  final int page;
  final int size;

  @override
  List<Object> get props => [projectId, page, size];
}
