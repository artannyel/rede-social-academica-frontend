import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class GetLessonDetail implements UseCase<Lesson, GetLessonDetailParams> {
  final MiniCourseRepository repository;

  GetLessonDetail(this.repository);

  @override
  Future<Either<Failure, Lesson>> call(GetLessonDetailParams params) async {
    return await repository.getLessonDetail(lessonId: params.lessonId);
  }
}

class GetLessonDetailParams extends Equatable {
  final String lessonId;

  const GetLessonDetailParams({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}