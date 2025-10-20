import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_user_ratings.dart';

enum UserRatingsState { idle, loading, loadingMore, success, error }

class UserRatingsChangeNotifier extends ChangeNotifier {
  final GetUserRatings _getUserRatingsUseCase;
  final String userId;

  UserRatingsChangeNotifier(this._getUserRatingsUseCase, this.userId);

  UserRatingsState _state = UserRatingsState.idle;
  UserRatingsState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UserRating> _ratings = [];
  List<UserRating> get ratings => _ratings;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialRatings() async {
    if (_state == UserRatingsState.loading) return;

    _state = UserRatingsState.loading;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getUserRatingsUseCase(
      GetUserRatingsParams(userId: userId, page: _currentPage),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = UserRatingsState.error;
        _ratings = [];
      },
      (paginatedResponse) {
        _ratings = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = UserRatingsState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreRatings() async {
    if (!_hasMorePages || _state == UserRatingsState.loadingMore) return;

    _state = UserRatingsState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getUserRatingsUseCase(
      GetUserRatingsParams(userId: userId, page: _currentPage),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = UserRatingsState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        _ratings.addAll(paginatedResponse.data);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = UserRatingsState.success;
      },
    );
    notifyListeners();
  }
}
