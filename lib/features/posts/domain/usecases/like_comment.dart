import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para curtir/descurtir um comentário.
class LikeComment implements UseCase<void, String> {
  final PostRepository repository;

  LikeComment(this.repository);

  @override
  Future<Either<Failure, void>> call(String commentId) =>
      repository.likeComment(commentId: commentId);
}
