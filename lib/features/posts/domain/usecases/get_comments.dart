import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para obter a lista paginada de comentários de um post.
class GetComments {
  final PostRepository repository;

  GetComments(this.repository);

  Future<Either<Failure, PaginatedResponse<Comment>>> call({
    required String postId,
    required int page,
  }) {
    return repository.getComments(postId: postId, page: page);
  }
}