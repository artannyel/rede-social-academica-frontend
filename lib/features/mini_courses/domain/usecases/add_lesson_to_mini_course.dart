import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class AddLessonToMiniCourse implements UseCase<Lesson, AddLessonParams> {
  final MiniCourseRepository repository;

  AddLessonToMiniCourse(this.repository);

  @override
  Future<Either<Failure, Lesson>> call(AddLessonParams params) async {
    return await repository.addLesson(
      miniCourseId: params.miniCourseId,
      title: params.title,
      description: params.description,
      youtubeUrl: params.youtubeUrl,
    );
  }
}

class AddLessonParams extends Equatable {
  final String miniCourseId;
  final String title;
  final String description;
  final String youtubeUrl;

  const AddLessonParams({required this.miniCourseId, required this.title, required this.description, required this.youtubeUrl});

  @override
  List<Object?> get props => [miniCourseId, title, description, youtubeUrl];
}