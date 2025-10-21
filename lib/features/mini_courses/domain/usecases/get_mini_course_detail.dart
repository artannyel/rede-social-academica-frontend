import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class GetMiniCourseDetail implements UseCase<MiniCourse, String> {
  final MiniCourseRepository repository;

  GetMiniCourseDetail(this.repository);

  @override
  Future<Either<Failure, MiniCourse>> call(String miniCourseId) async {
    return await repository.getMiniCourseDetail(miniCourseId: miniCourseId);
  }
}