import 'package:social_academic/features/authentication/data/models/user_model.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.comment,
    required super.createdAt,
    required UserModel super.user,
    required List<CommentModel> super.replies,
    required super.likesCount,
    required super.isLiked,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final repliesData = json['replies'] as List<dynamic>? ?? [];

    return CommentModel(
      id: json['id'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      // Adiciona uma verificação para garantir que 'user' não seja nulo.
      // Se for nulo, cria um UserModel "anônimo" para evitar que o app quebre.
      user: json['user'] != null ? UserModel.fromJson(json['user']) : const UserModel.anonymous(),
      replies: repliesData
          .map((replyJson) =>
              CommentModel.fromJson(replyJson as Map<String, dynamic>))
          .toList(),
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  /// Converte o modelo de dados em uma entidade de domínio.
  Comment toEntity() {
    return Comment(
      id: id,
      comment: comment,
      createdAt: createdAt,
      // UserModel é um subtipo de User, então a atribuição é válida.
      user: user,
      // Converte recursivamente a lista de replies (CommentModel) para uma lista de Comment (entidade).
      replies: replies.map((reply) => (reply as CommentModel).toEntity()).toList(),
      likesCount: likesCount,
      isLiked: isLiked,
    );
  }
}