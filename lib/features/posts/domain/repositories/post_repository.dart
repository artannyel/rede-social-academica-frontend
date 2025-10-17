import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, Post>> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  });

  /// Busca uma lista paginada de posts.
  Future<Either<Failure, PaginatedResponse<Post>>> getPosts({
    required int page,
  });

  /// Busca uma lista paginada dos posts do usuário logado.
  Future<Either<Failure, PaginatedResponse<Post>>> getMyPosts({
    required int page,
  });

  /// Curte ou descurte uma publicação.
  Future<Either<Failure, void>> likePost({required String postId});

  /// Curte ou descurte um comentário.
  Future<Either<Failure, void>> likeComment({required String commentId});

  /// Cria um novo comentário em uma publicação.
  Future<Either<Failure, void>> createComment({
    required String postId,
    required String comment,
    String? parentCommentId,
  });

  /// Busca os comentários de uma publicação.
  Future<Either<Failure, PaginatedResponse<Comment>>> getComments({
    required String postId,
    required int page,
  });
}
