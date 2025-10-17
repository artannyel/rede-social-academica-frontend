import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/usecases/get_posts.dart';
import 'package:social_academic/features/posts/domain/usecases/like_post.dart';

enum PostListState {
  idle,
  loadingInitial, // Para a primeira busca
  loadingMore,    // Para a paginação
  success,
  error,
}

class PostChangeNotifier extends ChangeNotifier {
  final GetPosts _getPostsUseCase;
  final LikePost _likePostUseCase;

  PostChangeNotifier(this._getPostsUseCase, this._likePostUseCase);

  PostListState _state = PostListState.idle;
  PostListState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  /// Busca a lista inicial de posts (página 1).
  /// Usado para o primeiro carregamento ou para "puxar para atualizar".
  Future<void> fetchInitialPosts() async {
    // Evita buscas duplicadas se já estiver carregando.
    if (_state == PostListState.loadingInitial) return;

    _state = PostListState.loadingInitial;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    final result = await _getPostsUseCase(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = PostListState.error;
        _posts = []; // Limpa os posts em caso de erro na busca inicial
      },
      (paginatedResponse) {
        _posts = paginatedResponse.data;
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = PostListState.success;
      },
    );
    notifyListeners();
  }

  /// Busca a próxima página de posts.
  Future<void> fetchMorePosts() async {
    // Só busca mais se houver mais páginas e não estiver carregando.
    if (!_hasMorePages || _state == PostListState.loadingMore) return;

    _state = PostListState.loadingMore;
    notifyListeners();

    _currentPage++;
    final result = await _getPostsUseCase(page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = PostListState.error; // Mantém os posts antigos e mostra o erro
        _currentPage--; // Volta a página em caso de erro
      },
      (paginatedResponse) {
        // Filtra posts duplicados antes de adicionar à lista.
        // Isso evita que posts que já foram carregados (e que podem ter "descido"
        // para páginas posteriores devido a novos posts no topo) sejam adicionados novamente.
        final newPosts = paginatedResponse.data.where((newPost) =>
            !_posts.any((existingPost) => existingPost.id == newPost.id)).toList();
        _posts.addAll(newPosts);
        _hasMorePages = paginatedResponse.hasMorePages;
        _state = PostListState.success;
      },
    );
    notifyListeners();
  }

  /// Curte ou descurte uma publicação com atualização otimista.
  Future<void> toggleLike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    // Salva o estado original para reverter em caso de falha.
    final originalPost = _posts[postIndex];
    final originalIsLiked = originalPost.isLiked;
    final originalLikesCount = originalPost.likesCount;

    // Atualização Otimista: atualiza a UI imediatamente.
    final postToUpdate = _posts[postIndex];
    postToUpdate.isLiked = !postToUpdate.isLiked;
    postToUpdate.likesCount = postToUpdate.isLiked
        ? postToUpdate.likesCount + 1
        : postToUpdate.likesCount - 1;
    notifyListeners();

    // Chama a API.
    final result = await _likePostUseCase(postId: postId);

    // Se a API falhar, reverte a alteração na UI.
    result.fold(
      (failure) {
        // Reverte para o estado original
        postToUpdate.isLiked = originalIsLiked;
        postToUpdate.likesCount = originalLikesCount;
        _errorMessage = failure.message;
        // Notifica os listeners para reverter a UI e potencialmente mostrar um erro.
        notifyListeners();
      },
      (_) {
        // Sucesso! A UI já está correta.
        // Podemos limpar qualquer mensagem de erro antiga.
        _errorMessage = null;
      },
    );
  }

  /// Adiciona um novo post no início da lista.
  void addNewPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }
}