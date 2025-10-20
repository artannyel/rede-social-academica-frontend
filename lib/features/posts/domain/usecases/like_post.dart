import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para curtir/descurtir uma publicação.
class LikePost implements UseCase<void, String> {
  final PostRepository repository;

  LikePost(this.repository);

  @override
  Future<Either<Failure, void>> call(String postId) =>
      repository.likePost(postId: postId);
}
