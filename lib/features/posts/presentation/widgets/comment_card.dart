import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/shared/widgets/user_avatar.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final bool isReply;
  final void Function(String commentId, String userName) onReply;

  const CommentCard({
    super.key,
    required this.comment,
    required this.onReply,
    this.isReply = false,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _showReplies = false;

  Comment get comment => widget.comment;
  bool get isReply => widget.isReply;
  void Function(String, String) get onReply => widget.onReply;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  photoUrl: comment.user.photoUrl,
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user.name,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('dd/MM/yy HH:mm').format(comment.createdAt),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.comment, style: textTheme.bodyMedium),
            const SizedBox(height: 8),
            _buildFooter(context, textTheme),
            if (_showReplies && comment.replies.isNotEmpty) _buildReplies(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        if (!isReply)
          TextButton(
            onPressed: () => onReply(comment.id, comment.user.name),
            child: const Text('Responder'),
          ),
        if (comment.replies.isNotEmpty && !isReply)
          TextButton(
            onPressed: () {
              setState(() {
                _showReplies = !_showReplies;
              });
            },
            child: Text(
              _showReplies
                  ? 'Ocultar respostas'
                  : 'Ver ${comment.replies.length} respostas',
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            // TODO: Implementar lógica de curtir comentário
          },
          icon: Icon(
            comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 16,
            color: comment.isLiked
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          label: Text(comment.likesCount.toString()),
        ),
      ],
    );
  }

  Widget _buildReplies(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
      child: Column(
        children: comment.replies
            .map((reply) => CommentCard(
                  comment: reply,
                  isReply: true,
                  onReply: onReply, // Passa a função, mas o botão não será exibido
                ))
            .toList(),
      ),
    );
  }
}