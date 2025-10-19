import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';
import 'package:social_academic/features/profile/domain/usecases/get_made_ratings.dart';

enum MadeRatingsState {
  idle,
  loading,
  loadingMore,
  success,
  error,
}

class MadeRatingsChangeNotifier extends ChangeNotifier {
  final GetMadeRatings _getMadeRatings;

  MadeRatingsChangeNotifier(this._getMadeRatings);

  MadeRatingsState _state = MadeRatingsState.idle;
  MadeRatingsState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UserRating> _ratings = [];
  List<UserRating> get ratings => _ratings;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialRatings() async {
    if (_state == MadeRatingsState.loading) return;

    _state = MadeRatingsState.loading;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getMadeRatings(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MadeRatingsState.error;
        _ratings = [];
      },
      (paginatedResponse) {
        _ratings = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MadeRatingsState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreRatings() async {
    if (!_hasMorePages || _state == MadeRatingsState.loadingMore) return;

    _state = MadeRatingsState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getMadeRatings(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MadeRatingsState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        final newRatings = paginatedResponse.data.where((newRating) =>
            !_ratings.any((existingRating) => existingRating.id == newRating.id)).toList();
        _ratings.addAll(newRatings);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MadeRatingsState.success;
      },
    );
    notifyListeners();
  }
}