import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

class GetArchivedPosts {
  final PostRepository repository;

  GetArchivedPosts(this.repository);

  Future<Either<Failure, PaginatedResponse<Post>>> call({required int page}) {
    return repository.getArchivedPosts(page: page);
  }
}