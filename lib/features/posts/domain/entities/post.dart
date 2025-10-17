import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/posts/domain/entities/post_image.dart';
import 'package:social_academic/features/posts/domain/entities/tag.dart';

class Post {
  final String id;
  final String publication;
  final bool sketch;
  final DateTime createdAt;
  final DateTime updatedAt;
  int likesCount;
  final int commentsCount;
  final List<PostImage> images; // Lista de URLs das imagens
  final User user;
  final List<Course> courses;
  final List<Tag> tags;
  bool isLiked;

  Post({
    required this.id,
    required this.publication,
    required this.sketch,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.images,
    required this.user,
    required this.courses,
    required this.tags,
    required this.isLiked,
  });

  Post copyWith({
    String? id,
    String? publication,
    bool? sketch,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    List<PostImage>? images,
    User? user,
    List<Course>? courses,
    List<Tag>? tags,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      publication: publication ?? this.publication,
      sketch: sketch ?? this.sketch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      images: images ?? this.images,
      user: user ?? this.user,
      courses: courses ?? this.courses,
      tags: tags ?? this.tags,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}