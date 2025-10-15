import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';

abstract class PostRepository {
  Future<Either<Failure, void>> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  });
}
