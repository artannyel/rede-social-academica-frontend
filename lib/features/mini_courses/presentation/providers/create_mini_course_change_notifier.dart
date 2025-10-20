import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/create_mini_course.dart';

enum CreateMiniCourseState { idle, loading, success, error }

class CreateMiniCourseChangeNotifier extends ChangeNotifier {
  final CreateMiniCourse _createMiniCourseUseCase;

  CreateMiniCourseChangeNotifier(this._createMiniCourseUseCase);

  CreateMiniCourseState _state = CreateMiniCourseState.idle;
  CreateMiniCourseState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MiniCourse? _createdMiniCourse;
  MiniCourse? get createdMiniCourse => _createdMiniCourse;

  Future<void> submitMiniCourse({
    required String title,
    required String description,
    XFile? photo,
    required List<String> courses,
  }) async {
    _state = CreateMiniCourseState.loading;
    notifyListeners();

    final result = await _createMiniCourseUseCase(CreateMiniCourseParams(
      title: title,
      description: description,
      photo: photo,
      courses: courses,
    ));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = CreateMiniCourseState.error;
      },
      (miniCourse) {
        _createdMiniCourse = miniCourse;
        _state = CreateMiniCourseState.success;
      },
    );
    notifyListeners();
  }

  void resetState() {
    _state = CreateMiniCourseState.idle;
    _errorMessage = null;
  }
}