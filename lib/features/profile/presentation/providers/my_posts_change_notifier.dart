import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/usecases/get_my_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/delete_post.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';

enum MyPostsListState { idle, loadingInitial, loadingMore, success, error }

class MyPostsChangeNotifier extends ChangeNotifier {
  final GetMyPosts _getMyPostsUseCase;
  final LikePost _likePostUseCase;
  final DeletePost _deletePostUseCase;

  MyPostsChangeNotifier(this._getMyPostsUseCase, this._likePostUseCase, this._deletePostUseCase);

  MyPostsListState _state = MyPostsListState.idle;
  MyPostsListState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialPosts() async {
    if (_state == MyPostsListState.loadingInitial) return;

    _state = MyPostsListState.loadingInitial;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getMyPostsUseCase(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MyPostsListState.error;
        _posts = [];
      },
      (paginatedResponse) {
        _posts = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MyPostsListState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMorePosts() async {
    if (!_hasMorePages || _state == MyPostsListState.loadingMore) return;

    _state = MyPostsListState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getMyPostsUseCase(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = MyPostsListState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        final newPosts = paginatedResponse.data
            .where(
              (newPost) =>
                  !_posts.any((existingPost) => existingPost.id == newPost.id),
            )
            .toList();
        _posts.addAll(newPosts);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = MyPostsListState.success;
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

    final result = await _likePostUseCase(postId: postId);

    result.fold((failure) {
      postToUpdate.isLiked = originalIsLiked;
      postToUpdate.likesCount = originalLikesCount;
      _errorMessage = failure.message;
      notifyListeners();
    }, (_) => _errorMessage = null);
  }

  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  Future<bool> deletePost(String postId) async {
    _errorMessage = null;
    notifyListeners();

    final result = await _deletePostUseCase(postId: postId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _posts.removeWhere((p) => p.id == postId);
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }
}
