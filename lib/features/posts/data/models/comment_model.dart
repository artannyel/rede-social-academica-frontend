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
      user: UserModel.fromJson(json['user']),
      replies: repliesData
          .map((replyJson) =>
              CommentModel.fromJson(replyJson as Map<String, dynamic>))
          .toList(),
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }
}