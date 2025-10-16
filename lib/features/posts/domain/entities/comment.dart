import 'package:social_academic/features/authentication/domain/entities/user.dart';

/// Entidade que representa um comentário em uma publicação.
class Comment {
  final String id;
  final String comment;
  final DateTime createdAt;
  final User user;
  final List<Comment> replies; // Para comentários aninhados
  int likesCount;
  bool isLiked;

  Comment({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.user,
    required this.replies,
    required this.likesCount,
    required this.isLiked,
  });
}