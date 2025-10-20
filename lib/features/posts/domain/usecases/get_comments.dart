import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para obter a lista paginada de comentários de um post.
class GetComments
    implements UseCase<PaginatedResponse<Comment>, GetCommentsParams> {
  final PostRepository repository;

  GetComments(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<Comment>>> call(
    GetCommentsParams params,
  ) {
    return repository.getComments(postId: params.postId, page: params.page);
  }
}

class GetCommentsParams extends Equatable {
  final String postId;
  final int page;

  const GetCommentsParams({required this.postId, required this.page});

  @override
  List<Object?> get props => [postId, page];
}
