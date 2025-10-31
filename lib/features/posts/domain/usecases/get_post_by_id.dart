import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

class GetPostById {
  final PostRepository repository;

  GetPostById(this.repository);

  Future<Either<Failure, Post>> call(String postId) async {
    return await repository.getPostById(postId: postId);
  }
}