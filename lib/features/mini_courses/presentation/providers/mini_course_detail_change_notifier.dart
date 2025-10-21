import 'package:flutter/material.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_course_detail.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/publish_mini_course.dart';

enum MiniCourseDetailState { idle, loading, success, error }

class MiniCourseDetailChangeNotifier extends ChangeNotifier {
  final GetMiniCourseDetail _getMiniCourseDetail;
  final PublishMiniCourse _publishMiniCourse;
  final String miniCourseId;

  MiniCourseDetailChangeNotifier(this._getMiniCourseDetail, this._publishMiniCourse, this.miniCourseId);

  MiniCourseDetailState _state = MiniCourseDetailState.idle;
  MiniCourseDetailState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MiniCourse? _miniCourse;
  MiniCourse? get miniCourse => _miniCourse;

  Future<void> fetchMiniCourseDetail() async {
    if (_state == MiniCourseDetailState.loading) return;

    _state = MiniCourseDetailState.loading;
    notifyListeners();

    final result = await _getMiniCourseDetail(miniCourseId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MiniCourseDetailState.error;
      },
      (course) {
        _miniCourse = course;
        _state = MiniCourseDetailState.success;
      },
    );
    notifyListeners();
  }

  void updateCourse(MiniCourse course) {
    _miniCourse = course;
    notifyListeners();
  }

  Future<bool> publishCourse() async {
    final result = await _publishMiniCourse(miniCourseId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedCourse) {
        _miniCourse = updatedCourse;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }
}