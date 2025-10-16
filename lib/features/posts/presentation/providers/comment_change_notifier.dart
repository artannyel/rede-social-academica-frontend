import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/features/posts/domain/usecases/create_comment.dart';
import 'package:social_academic/features/posts/domain/usecases/get_comments.dart';

enum CommentState { idle, loading, loadingMore, success, error, submitting }

class CommentChangeNotifier extends ChangeNotifier {
  final GetComments _getComments;
  final CreateComment _createComment;
  final String postId;

  CommentChangeNotifier({
    required this.postId,
    required GetComments getComments,
    required CreateComment createComment,
  })  : _getComments = getComments,
        _createComment = createComment {
    fetchInitialComments();
  }

  CommentState _state = CommentState.idle;
  CommentState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchInitialComments() async {
    _state = CommentState.loading;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getComments(postId: postId, page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = CommentState.error;
        _comments = [];
      },
      (paginatedResponse) {
        _comments = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = CommentState.success;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreComments() async {
    if (!_hasMorePages || _state == CommentState.loadingMore) return;

    _state = CommentState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getComments(postId: postId, page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = CommentState.error;
        _currentPage--;
      },
      (paginatedResponse) {
        _comments.addAll(paginatedResponse.data);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = CommentState.success;
      },
    );
    notifyListeners();
  }

  Future<bool> submitComment({
    required String comment,
    String? parentCommentId,
  }) async {
    _state = CommentState.submitting;
    _errorMessage = null;
    notifyListeners();

    final result = await _createComment(
      postId: postId,
      comment: comment,
      parentCommentId: parentCommentId,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = CommentState.error;
        notifyListeners();
        return false;
      },
      (_) {
        _state = CommentState.success;
        // Após o sucesso, busca novamente os comentários para exibir o novo.
        // Uma abordagem mais otimizada seria adicionar o comentário retornado pela API
        // diretamente na lista, mas isso requer que a API retorne o comentário criado.
        fetchInitialComments();
        return true;
      },
    );
  }
}