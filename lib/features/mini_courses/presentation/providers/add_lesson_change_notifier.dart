import 'package:flutter/material.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/add_lesson_to_mini_course.dart';

enum AddLessonState { idle, loading, success, error }

class AddLessonChangeNotifier extends ChangeNotifier {
  final AddLessonToMiniCourse _addLessonUseCase;

  AddLessonChangeNotifier(this._addLessonUseCase);

  AddLessonState _state = AddLessonState.idle;
  AddLessonState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Lesson? _createdLesson;
  Lesson? get createdLesson => _createdLesson;

  Future<void> submitLesson({
    required String miniCourseId,
    required String title,
    required String description,
    required String youtubeUrl,
  }) async {
    _state = AddLessonState.loading;
    notifyListeners();

    final result = await _addLessonUseCase(AddLessonParams(
      miniCourseId: miniCourseId,
      title: title,
      description: description,
      youtubeUrl: youtubeUrl,
    ));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = AddLessonState.error;
      },
      (lesson) {
        _createdLesson = lesson;
        _state = AddLessonState.success;
      },
    );
    notifyListeners();
  }

  void resetState() {
    _state = AddLessonState.idle;
    _errorMessage = null;
  }
}