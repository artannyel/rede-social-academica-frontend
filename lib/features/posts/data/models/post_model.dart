import 'package:social_academic/features/authentication/data/models/user_model.dart';
import 'package:social_academic/features/courses/data/models/course_model.dart';
import 'package:social_academic/features/posts/data/models/post_image_model.dart';
import 'package:social_academic/features/posts/data/models/tag_model.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.publication,
    required super.sketch,
    required super.createdAt,
    required super.updatedAt,
    required super.likesCount,
    required super.commentsCount,
    required super.images,
    required UserModel super.user,
    required List<CourseModel> super.courses,
    required List<TagModel> super.tags,
    required super.isLiked,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final imagesData = json['images'] as List<dynamic>?;
    final coursesData = json['courses'] as List<dynamic>?;
    final tagsData = json['tags'] as List<dynamic>?;

    return PostModel(
      id: json['id'],
      publication: json['publication'],
      sketch: json['sketch'],
      createdAt: DateTime.parse(json['created_at']).toLocal(), // Convertido para horário local
      updatedAt: DateTime.parse(json['updated_at']).toLocal(), // Convertido para horário local
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      images:
          imagesData
              ?.map((imageData) => PostImageModel.fromJson(imageData).urlImage)
              .toList() ??
          [],
      isLiked: json['is_liked'] ?? false,
      user: UserModel.fromJson(json['user']),
      courses:
          coursesData
              ?.map((courseData) => CourseModel.fromJson(courseData))
              .toList() ??
          [],
      tags:
          tagsData?.map((tagData) => TagModel.fromJson(tagData)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publication': publication,
      'sketch': sketch,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      // A conversão de volta para o formato de imagem completo não é trivial
      // e geralmente não é necessária no cliente. Se for, precisaria de mais lógica.
      'images': images,
      'is_liked': isLiked,
      'user': (user as UserModel).toJson(),
      'courses': (courses as List<CourseModel>)
          .map((course) => course.toJson())
          .toList(),
      'tags': (tags as List<TagModel>).map((tag) => tag.toJson()).toList(),
    };
  }

  /// Converte este modelo de dados em uma entidade de domínio.
  /// Como PostModel já é um subtipo de Post, podemos simplesmente retornar `this`.
  /// No entanto, para manter a consistência com o padrão `toEntity()`,
  /// e garantir que os objetos aninhados também sejam convertidos,
  /// é mais seguro reconstruir o objeto.
  Post toEntity() {
    return Post(
      id: id,
      publication: publication,
      sketch: sketch,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user, // UserModel é um subtipo de User
      tags: tags, // TagModel é um subtipo de Tag
      images: images,
      courses: courses, // CourseModel é um subtipo de Course
    );
  }
}
