import 'package:flutter/material.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/courses/domain/usecases/get_courses.dart';

enum CourseState { idle, loading, success, error }

class CourseChangeNotifier extends ChangeNotifier {
  final GetCourses _getCoursesUseCase;

  CourseChangeNotifier(this._getCoursesUseCase);

  CourseState _state = CourseState.idle;
  CourseState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Course> _courses = [];
  List<Course> get courses => _courses;

  Future<void> fetchCourses() async {
    _state = CourseState.loading;
    notifyListeners();

    final result = await _getCoursesUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = CourseState.error;
      },
      (courses) {
        _courses = courses;
        _state = CourseState.success;
      },
    );
    notifyListeners();
  }

  /// Limpa a lista de cursos e reseta o estado.
  /// Útil ao sair de uma tela que carregou os cursos, como a de registro.
  void clearCourses() {
    _courses = [];
    _state = CourseState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}