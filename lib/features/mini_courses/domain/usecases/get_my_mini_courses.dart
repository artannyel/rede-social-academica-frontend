import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class GetMyMiniCourses
    implements UseCase<PaginatedResponse<MiniCourse>, GetMyMiniCoursesParams> {
  final MiniCourseRepository repository;

  GetMyMiniCourses(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<MiniCourse>>> call(
      GetMyMiniCoursesParams params) async {
    return await repository.getMyMiniCourses(page: params.page);
  }
}

class GetMyMiniCoursesParams extends Equatable {
  final int page;

  GetMyMiniCoursesParams({required this.page});

  @override
  List<Object?> get props => [page];
}