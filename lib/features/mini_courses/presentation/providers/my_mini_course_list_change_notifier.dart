import 'package:flutter/material.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/get_my_mini_courses.dart';

enum MyMiniCourseListState {
  idle,
  loadingInitial,
  loadingMore,
  success,
  error
}

class MyMiniCourseListChangeNotifier extends ChangeNotifier {
  final GetMyMiniCourses _getMiniCourses;

  MyMiniCourseListChangeNotifier(this._getMiniCourses);

  MyMiniCourseListState _state = MyMiniCourseListState.idle;
  MyMiniCourseListState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MiniCourse> _miniCourses = [];
  List<MiniCourse> get miniCourses => _miniCourses;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialMiniCourses() async {
    if (_state == MyMiniCourseListState.loadingInitial) return;

    _state = MyMiniCourseListState.loadingInitial;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getMiniCourses(GetMyMiniCoursesParams(page: _currentPage));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MyMiniCourseListState.error;
        _miniCourses = []; // Limpa a lista em caso de erro inicial
      },
      (paginatedResponse) {
        _miniCourses = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MyMiniCourseListState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreMiniCourses() async {
    if (!_hasMorePages || _state == MyMiniCourseListState.loadingMore) return;

    _state = MyMiniCourseListState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getMiniCourses(GetMyMiniCoursesParams(page: _currentPage));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MyMiniCourseListState.error;
        _currentPage--; // Reverte a página em caso de erro
      },
      (paginatedResponse) {
        // Evita adicionar itens duplicados
        final newItems = paginatedResponse.data.where((newItem) =>
            !_miniCourses.any((existingItem) => existingItem.id == newItem.id)).toList();
        _miniCourses.addAll(newItems);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MyMiniCourseListState.success;
      },
    );
    notifyListeners();
  }

  void addMiniCourse(MiniCourse miniCourse) {
    _miniCourses.insert(0, miniCourse);
    notifyListeners();
  }

  void updateMiniCourse(MiniCourse updatedMiniCourse) {
    final index =
        _miniCourses.indexWhere((course) => course.id == updatedMiniCourse.id);
    if (index != -1) {
      _miniCourses[index] = updatedMiniCourse;
      notifyListeners();
    }
  }

  void removeMiniCourse(String miniCourseId) {
    _miniCourses.removeWhere((course) => course.id == miniCourseId);
    notifyListeners();
  }
}