import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class GetMiniCourses implements UseCase<PaginatedResponse<MiniCourse>, int> {
  final MiniCourseRepository repository;

  GetMiniCourses(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<MiniCourse>>> call(int params) async {
    return await repository.getMiniCourses(page: params);
  }
}