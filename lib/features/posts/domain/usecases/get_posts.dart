import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para obter a lista paginada de posts.
class GetPosts implements UseCase<PaginatedResponse<Post>, int> {
  final PostRepository repository;

  GetPosts(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<Post>>> call(int page) {
    return repository.getPosts(page: page);
  }
}
