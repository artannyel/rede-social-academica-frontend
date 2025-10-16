import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para curtir/descurtir um comentário.
class LikeComment {
  final PostRepository repository;

  LikeComment(this.repository);

  Future<Either<Failure, void>> call({required String commentId}) =>
      repository.likeComment(commentId: commentId);
}
