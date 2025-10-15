import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/tag.dart';

abstract class TagRepository {
  Future<Either<Failure, List<Tag>>> getTags();
}
