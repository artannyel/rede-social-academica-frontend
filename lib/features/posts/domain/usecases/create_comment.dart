import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para criar um novo comentário.
class CreateComment {
  final PostRepository repository;

  CreateComment(this.repository);

  Future<Either<Failure, void>> call({
    required String postId,
    required String comment,
    String? parentCommentId,
  }) {
    return repository.createComment(
      postId: postId,
      comment: comment,
      parentCommentId: parentCommentId,
    );
  }
}