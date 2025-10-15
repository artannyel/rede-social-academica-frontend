import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/tag.dart';
import 'package:social_academic/features/posts/domain/repositories/tag_repository.dart';

class GetTags {
  final TagRepository repository;

  GetTags(this.repository);

  Future<Either<Failure, List<Tag>>> call() => repository.getTags();
}
