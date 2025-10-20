import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';

abstract class MiniCourseRepository {
  Future<Either<Failure, MiniCourse>> createMiniCourse({
    required String title,
    required String description,
    XFile? photo,
    required List<String> courses,
  });

  Future<Either<Failure, PaginatedResponse<MiniCourse>>> getMiniCourses({required int page});
}