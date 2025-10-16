import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/features/posts/domain/usecases/create_comment.dart';
import 'package:social_academic/features/posts/domain/usecases/get_comments.dart';
import 'package:social_academic/features/posts/domain/usecases/like_comment.dart';

enum CommentState { idle, loading, loadingMore, success, error, submitting }

class CommentChangeNotifier extends ChangeNotifier {
  final GetComments _getComments;
  final CreateComment _createComment;
  final LikeComment _likeComment;
  final String postId;

  CommentChangeNotifier({
    required this.postId,
    required GetComments getComments,
    required CreateComment createComment,
    required LikeComment likeComment,
  })  : _getComments = getComments,
        _createComment = createComment,
        _likeComment = likeComment {
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

  // Função auxiliar recursiva para encontrar um comentário por ID em qualquer nível.
  Comment? _findCommentById(List<Comment> comments, String id) {
    for (final comment in comments) {
      if (comment.id == id) {
        return comment;
      }
      final foundInReplies = _findCommentById(comment.replies, id);
      if (foundInReplies != null) {
        return foundInReplies;
      }
    }
    return null;
  }

  Future<void> toggleLike(String commentId) async {
    final targetComment = _findCommentById(_comments, commentId);

    if (targetComment == null) return;

    // Atualização Otimista
    targetComment.isLiked = !targetComment.isLiked;
    targetComment.isLiked ? targetComment.likesCount++ : targetComment.likesCount--;
    notifyListeners();

    final result = await _likeComment(commentId: commentId);

    // Reverte em caso de erro
    result.fold((failure) {
      targetComment.isLiked = !targetComment.isLiked;
      targetComment.isLiked ? targetComment.likesCount++ : targetComment.likesCount--;
      _errorMessage = failure.message;
      _state = CommentState.error; // ou um estado de erro específico para like
      notifyListeners();
    }, (_) => null);
  }
}