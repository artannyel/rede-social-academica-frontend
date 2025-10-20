import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class CreateMiniCourse implements UseCase<MiniCourse, CreateMiniCourseParams> {
  final MiniCourseRepository repository;

  CreateMiniCourse(this.repository);

  @override
  Future<Either<Failure, MiniCourse>> call(CreateMiniCourseParams params) async {
    return await repository.createMiniCourse(
      title: params.title,
      description: params.description,
      photo: params.photo,
      courses: params.courses,
    );
  }
}

class CreateMiniCourseParams {
  final String title;
  final String description;
  final XFile? photo;
  final List<String> courses;

  CreateMiniCourseParams({
    required this.title,
    required this.description,
    this.photo,
    required this.courses,
  });
}