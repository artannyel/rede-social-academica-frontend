import 'package:flutter/material.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_mini_courses.dart';

enum MiniCourseListState {
  idle,
  loadingInitial,
  loadingMore,
  success,
  error,
}

class MiniCourseListChangeNotifier extends ChangeNotifier {
  final GetMiniCourses _getMiniCoursesUseCase;

  MiniCourseListChangeNotifier(this._getMiniCoursesUseCase);

  MiniCourseListState _state = MiniCourseListState.idle;
  MiniCourseListState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MiniCourse> _miniCourses = [];
  List<MiniCourse> get miniCourses => _miniCourses;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialMiniCourses() async {
    if (_state == MiniCourseListState.loadingInitial) return;

    _state = MiniCourseListState.loadingInitial;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getMiniCoursesUseCase(_currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MiniCourseListState.error;
        _miniCourses = [];
      },
      (paginatedResponse) {
        _miniCourses = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MiniCourseListState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreMiniCourses() async {
    if (!_hasMorePages || _state == MiniCourseListState.loadingMore) return;

    _state = MiniCourseListState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getMiniCoursesUseCase(_currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MiniCourseListState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        final newItems = paginatedResponse.data.where((newItem) =>
            !_miniCourses.any((existingItem) => existingItem.id == newItem.id)).toList();
        _miniCourses.addAll(newItems);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MiniCourseListState.success;
      },
    );
    notifyListeners();
  }

  /// Adiciona um novo mini curso no início da lista.
  void addNewMiniCourse(MiniCourse miniCourse) {
    _miniCourses.insert(0, miniCourse);
    notifyListeners();
  }
}