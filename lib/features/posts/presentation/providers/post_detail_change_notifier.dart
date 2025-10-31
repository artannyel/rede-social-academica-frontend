import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/usecases/get_post_by_id.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';

enum PostDetailState { initial, loading, success, error }

class PostDetailChangeNotifier extends ChangeNotifier {
  final GetPostById getPostById;
  final LikePost likePost;

  PostDetailChangeNotifier({required this.getPostById, required this.likePost});

  PostDetailState _state = PostDetailState.initial;
  PostDetailState get state => _state;

  Post? _post;
  Post? get post => _post;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPost(String postId) async {
    _state = PostDetailState.loading;
    notifyListeners();

    final result = await getPostById(postId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = PostDetailState.error;
      },
      (post) {
        _post = post;
        _state = PostDetailState.success;
      },
    );
    notifyListeners();
  }

  Future<void> toggleLike() async {
    if (_post == null) return;

    final originalPost = _post!;
    _post = originalPost.copyWith(isLiked: !originalPost.isLiked, likesCount: originalPost.isLiked ? originalPost.likesCount - 1 : originalPost.likesCount + 1);
    notifyListeners();

    await likePost(_post!.id);
  }
}