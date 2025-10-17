import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

class CreatePost {
  final PostRepository repository;

  CreatePost(this.repository);

  Future<Either<Failure, Post>> call({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  }) {
    return repository.createPost(
      publication: publication,
      tags: tags,
      courses: courses,
      images: images,
    );
  }
}
