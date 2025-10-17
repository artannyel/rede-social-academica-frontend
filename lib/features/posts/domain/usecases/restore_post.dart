import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

class RestorePost {
  final PostRepository repository;

  RestorePost(this.repository);

  Future<Either<Failure, void>> call({required String postId}) {
    return repository.restorePost(postId: postId);
  }
}