import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/courses/domain/repositories/course_repository.dart';

/// Caso de uso para obter a lista de cursos.
class GetCourses {
  final CourseRepository repository;

  GetCourses(this.repository);

  /// O método `call` permite que a classe seja chamada como uma função.
  Future<Either<Failure, List<Course>>> call() async {
    return await repository.getCourses();
  }
}