import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';
import 'package:social_academic/features/profile/domain/usecases/get_received_ratings.dart';

enum ReceivedRatingsState {
  idle,
  loading,
  loadingMore,
  success,
  error,
}

class ReceivedRatingsChangeNotifier extends ChangeNotifier {
  final GetReceivedRatings _getReceivedRatings;

  ReceivedRatingsChangeNotifier(this._getReceivedRatings);

  ReceivedRatingsState _state = ReceivedRatingsState.idle;
  ReceivedRatingsState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UserRating> _ratings = [];
  List<UserRating> get ratings => _ratings;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialRatings() async {
    if (_state == ReceivedRatingsState.loading) return;

    _state = ReceivedRatingsState.loading;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getReceivedRatings(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ReceivedRatingsState.error;
        _ratings = [];
      },
      (paginatedResponse) {
        _ratings = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = ReceivedRatingsState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreRatings() async {
    if (!_hasMorePages || _state == ReceivedRatingsState.loadingMore) return;

    _state = ReceivedRatingsState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getReceivedRatings(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ReceivedRatingsState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        final newRatings = paginatedResponse.data.where((newRating) =>
            !_ratings.any((existingRating) => existingRating.id == newRating.id)).toList();
        _ratings.addAll(newRatings);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = ReceivedRatingsState.success;
      },
    );
    notifyListeners();
  }
}