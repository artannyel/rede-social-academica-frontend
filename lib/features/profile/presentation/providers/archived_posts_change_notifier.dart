import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/usecases/force_delete_post.dart';
import 'package:social_academic/features/posts/domain/usecases/get_archived_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/restore_post.dart';

enum ArchivedPostsListState { idle, loadingInitial, loadingMore, success, error }

class ArchivedPostsChangeNotifier extends ChangeNotifier {
  final GetArchivedPosts _getArchivedPostsUseCase;
  final RestorePost _restorePostUseCase;
  final ForceDeletePost _forceDeletePostUseCase;

  ArchivedPostsChangeNotifier(this._getArchivedPostsUseCase,
      this._restorePostUseCase, this._forceDeletePostUseCase);

  ArchivedPostsListState _state = ArchivedPostsListState.idle;
  ArchivedPostsListState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialPosts() async {
    if (_state == ArchivedPostsListState.loadingInitial) return;

    _state = ArchivedPostsListState.loadingInitial;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getArchivedPostsUseCase(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ArchivedPostsListState.error;
        _posts = [];
      },
      (paginatedResponse) {
        _posts = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = ArchivedPostsListState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMorePosts() async {
    if (!_hasMorePages || _state == ArchivedPostsListState.loadingMore) return;

    _state = ArchivedPostsListState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getArchivedPostsUseCase(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ArchivedPostsListState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        _posts.addAll(paginatedResponse.data);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = ArchivedPostsListState.success;
      },
    );
    notifyListeners();
  }

  Future<bool> restorePost(String postId) async {
    final result = await _restorePostUseCase(postId: postId);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> forceDeletePost(String postId) async {
    final result = await _forceDeletePostUseCase(postId: postId);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      },
    );
  }
}