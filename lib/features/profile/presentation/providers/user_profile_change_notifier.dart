import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/entities/user_profile.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_user_profile.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/authentication/domain/usecases/rate_user.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';

enum UserProfileState { idle, loading, loadingMore, success, error }

class UserProfileChangeNotifier extends ChangeNotifier {
  final GetUserProfile _getUserProfileUseCase;
  final LikePost _likePostUseCase;
  final RateUser _rateUserUseCase;
  final String userId;

  UserProfileChangeNotifier(
    this._getUserProfileUseCase,
    this._likePostUseCase,
    this._rateUserUseCase,
    this.userId,
  );

  UserProfileState _state = UserProfileState.idle;
  UserProfileState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialProfile() async {
    if (_state == UserProfileState.loading) return;

    _state = UserProfileState.loading;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getUserProfileUseCase(
      GetUserProfileParams(userId: userId, page: _currentPage),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = UserProfileState.error;
        _user = null;
        _posts = [];
      },
      (userProfile) {
        _userProfile = userProfile;
        _user = userProfile.user;
        _posts = userProfile.posts.data;
        _hasMorePages = userProfile.posts.hasMorePages;
        _state = UserProfileState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMorePosts() async {
    if (!_hasMorePages || _state == UserProfileState.loadingMore) return;

    _state = UserProfileState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getUserProfileUseCase(
      GetUserProfileParams(userId: userId, page: _currentPage),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = UserProfileState.error;
        _currentPage--;
      },
      (userProfile) {
        _userProfile = userProfile;
        _posts.addAll(userProfile.posts.data);
        _hasMorePages = userProfile.posts.hasMorePages;
        _state = UserProfileState.success;
      },
    );
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final originalPost = _posts[postIndex];
    final originalIsLiked = originalPost.isLiked;
    final originalLikesCount = originalPost.likesCount;

    final postToUpdate = _posts[postIndex];
    postToUpdate.isLiked = !postToUpdate.isLiked;
    postToUpdate.likesCount = postToUpdate.isLiked
        ? postToUpdate.likesCount + 1
        : postToUpdate.likesCount - 1;
    notifyListeners();

    final result = await _likePostUseCase(postId);

    result.fold((failure) {
      postToUpdate.isLiked = originalIsLiked;
      postToUpdate.likesCount = originalLikesCount;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) => _errorMessage = null);
  }

  Future<bool> submitRating({
    required int rate,
    required String message,
  }) async {
    _errorMessage = null;
    notifyListeners();

    final result = await _rateUserUseCase(
      RateUserParams(userId: userId, rate: rate, message: message),
    );

    return result.fold((failure) {
      _errorMessage = failure.message;
      return false;
    }, (_) => true);
  }
}
