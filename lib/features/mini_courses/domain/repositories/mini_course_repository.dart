import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';

abstract class MiniCourseRepository {
  Future<Either<Failure, MiniCourse>> createMiniCourse({
    required String title,
    required String description,
    XFile? photo,
    required List<String> courses,
  });

  Future<Either<Failure, PaginatedResponse<MiniCourse>>> getMiniCourses({required int page});

  Future<Either<Failure, PaginatedResponse<MiniCourse>>> getMyMiniCourses({
    required int page,
  });

  Future<Either<Failure, void>> enrollMiniCourse({required String miniCourseId});

  Future<Either<Failure, MiniCourse>> getMiniCourseDetail({required String miniCourseId});

  Future<Either<Failure, MiniCourse>> publishMiniCourse({required String miniCourseId});

  Future<Either<Failure, Lesson>> addLesson({
    required String miniCourseId,
    required String title,
    required String description,
    required String youtubeUrl,
  });
}