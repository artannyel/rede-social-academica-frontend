import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class EnrollMiniCourse implements UseCase<void, String> {
  final MiniCourseRepository repository;

  EnrollMiniCourse(this.repository);

  @override
  Future<Either<Failure, void>> call(String miniCourseId) async {
    return await repository.enrollMiniCourse(miniCourseId: miniCourseId);
  }
}