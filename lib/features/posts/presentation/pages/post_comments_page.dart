import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/posts/presentation/providers/comment_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/comment_card.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';

class PostCommentsPage extends StatelessWidget {
  final String postId;
  const PostCommentsPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 1. O Provider agora é criado aqui, no widget pai.
      create: (context) => CommentChangeNotifier(
        postId: postId,
        getComments: context.read(),
        createComment: context.read(),
        likeComment: context.read(),
      ),
      child: const _PostCommentsView(), // 2. O conteúdo da página agora está em um widget filho.
    );
  }
}

class _PostCommentsView extends StatefulWidget {
  const _PostCommentsView();

  @override
  State<_PostCommentsView> createState() => _PostCommentsViewState();
}

class _PostCommentsViewState extends State<_PostCommentsView> {
  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();

  String? _replyingToCommentId;
  String? _replyingToUserName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        context.read<CommentChangeNotifier>().fetchMoreComments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _handleReply(String commentId, String userName) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUserName = userName;
      // Foca no campo de texto para facilitar a digitação da resposta.
      _commentFocusNode.requestFocus();
    });
  }

  void _submitComment(CommentChangeNotifier notifier) async {
    if (_commentController.text.trim().isEmpty) return;

    final success = await notifier.submitComment(
      comment: _commentController.text.trim(),
      parentCommentId: _replyingToCommentId,
    );

    if (success) {
      _commentController.clear();
      setState(() {
        _replyingToCommentId = null;
        _replyingToUserName = null;
      });
      FocusScope.of(context).unfocus(); // Esconde o teclado
    } else {
      if (mounted) {
        showAppSnackBar(
          context,
          message: notifier.errorMessage ?? 'Falha ao enviar comentário.',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
      ),
      resizeToAvoidBottomInset: false,
      body: Consumer<CommentChangeNotifier>(
        builder: (context, notifier, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCommentsList(notifier),
                    ),
                    _buildCommentInputField(notifier),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentsList(CommentChangeNotifier notifier) {
    if (notifier.state == CommentState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.state == CommentState.error && notifier.comments.isEmpty) {
      return Center(
        child: Text(notifier.errorMessage ?? 'Erro ao carregar comentários.'),
      );
    }

    if (notifier.comments.isEmpty) {
      return const Center(child: Text('Nenhum comentário ainda.'));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetchInitialComments(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount:
            notifier.comments.length + (notifier.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == notifier.comments.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final comment = notifier.comments[index];
          return CommentCard(
            comment: comment,
            onReply: _handleReply,
            // A função onLike agora recebe o ID do comentário que foi clicado,
            // seja o principal ou uma de suas respostas.
            onLike: (String commentId) => notifier.toggleLike(commentId),
          );
        },
      ),
    );
  }

  Widget _buildCommentInputField(CommentChangeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToCommentId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    'Respondendo a $_replyingToUserName',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _replyingToCommentId = null;
                        _replyingToUserName = null;
                      });
                    },
                  )
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Adicione um comentário...',
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(notifier),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: notifier.state == CommentState.submitting
                    ? null
                    : () => _submitComment(notifier),
              ),
            ],
          ),
        ],
      ),
    );
  }
}