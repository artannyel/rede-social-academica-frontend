import 'package:flutter/material.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_lesson_detail.dart';

enum LessonPlayerState { idle, loading, loaded, error }

class LessonPlayerChangeNotifier extends ChangeNotifier {
  final GetLessonDetail _getLessonDetail;
  final String _lessonId;

  LessonPlayerChangeNotifier(this._getLessonDetail, this._lessonId);

  LessonPlayerState _state = LessonPlayerState.idle;
  LessonPlayerState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Lesson? _lesson;
  Lesson? get lesson => _lesson;

  Future<void> fetchLessonDetail() async {
    if (_state == LessonPlayerState.loading) return; // Prevent multiple fetches

    _state = LessonPlayerState.loading;
    notifyListeners();

    final result = await _getLessonDetail(GetLessonDetailParams(lessonId: _lessonId));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = LessonPlayerState.error;
      },
      (lesson) {
        _lesson = lesson;
        _state = LessonPlayerState.loaded;
      },
    );
    notifyListeners();
  }

  void resetState() {
    _state = LessonPlayerState.idle;
    _errorMessage = null;
    _lesson = null;
    notifyListeners();
  }
}