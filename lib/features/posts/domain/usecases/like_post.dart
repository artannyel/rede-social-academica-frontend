import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para curtir/descurtir uma publicação.
class LikePost {
  final PostRepository repository;

  LikePost(this.repository);

  Future<Either<Failure, void>> call({required String postId}) =>
      repository.likePost(postId: postId);
}