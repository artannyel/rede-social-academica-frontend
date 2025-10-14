import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';

/// Contrato do repositório para a entidade Course.
abstract class CourseRepository {
  Future<Either<Failure, List<Course>>> getCourses();
}