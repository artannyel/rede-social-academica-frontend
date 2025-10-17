import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

class EditPost {
  final PostRepository repository;

  EditPost(this.repository);

  Future<Either<Failure, Post>> call({
    required String postId,
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? newImages,
    List<String>? removedImageIds,
  }) {
    return repository.editPost(
      postId: postId,
      publication: publication,
      tags: tags,
      courses: courses,
      newImages: newImages,
      removedImageIds: removedImageIds,
    );
  }
}