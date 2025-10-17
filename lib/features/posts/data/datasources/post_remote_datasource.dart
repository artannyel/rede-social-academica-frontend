import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/data/models/paginated_response.dart';
import 'package:social_academic/features/posts/data/models/comment_model.dart';
import 'package:social_academic/features/posts/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<PostModel> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  });

  /// Busca uma lista paginada de posts.
  Future<PaginatedResponse<PostModel>> getPosts({
    required int page,
  });

  /// Busca uma lista paginada dos posts do usuário logado.
  Future<PaginatedResponse<PostModel>> getMyPosts({
    required int page,
  });

  /// Curte ou descurte uma publicação.
  Future<void> likePost({required String postId});

  /// Curte ou descurte um comentário.
  Future<void> likeComment({required String commentId});

  /// Cria um novo comentário em uma publicação.
  Future<void> createComment({
    required String postId,
    required String comment,
    String? parentCommentId,
  });

  /// Busca os comentários de uma publicação.
  Future<PaginatedResponse<CommentModel>> getComments({
    required String postId,
    required int page,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  PostRemoteDataSourceImpl({required this.dio, required this.firebaseAuth});

  @override
  Future<PostModel> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  }) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    // Criamos o FormData e adicionamos os campos manualmente para garantir
    // a formatação correta de array que o Laravel espera (ex: tags[]).
    final formData = FormData();
    formData.fields.add(MapEntry('publication', publication));

    // Adiciona cada tag e curso com a sintaxe de array
    for (final tagId in tags) {
      formData.fields.add(MapEntry('tags[]', tagId));
    }
    for (final courseId in courses) {
      formData.fields.add(MapEntry('courses[]', courseId));
    }

    if (images != null && images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final bytes = await image.readAsBytes();
        formData.files.add(
          MapEntry(
            'images[]',
            // Usamos fromBytes, que funciona tanto em mobile quanto na web.
            MultipartFile.fromBytes(bytes, filename: image.name),
          ),
        );
      }
    }

    final response = await dio.post(
      '/posts',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Converte a resposta JSON em um PostModel.
    return PostModel.fromJson(response.data);
  }

  @override
  Future<PaginatedResponse<PostModel>> getPosts({required int page}) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await dio.get(
      '/posts',
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Usa o factory do PaginatedResponse para desserializar a resposta completa,
    // passando a função de conversão para o PostModel.
    return PaginatedResponse.fromJson(response.data, PostModel.fromJson);
  }

  @override
  Future<void> likePost({required String postId}) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    await dio.post(
      '/posts/$postId/like',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Future<void> likeComment({required String commentId}) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    await dio.post(
      '/comments/$commentId/like',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Future<void> createComment({
    required String postId,
    required String comment,
    String? parentCommentId,
  }) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final data = {
      'comment': comment,
    };

    if (parentCommentId != null) {
      data['post_comment_id'] = parentCommentId;
    }

    await dio.post(
      '/posts/$postId/comments',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Future<PaginatedResponse<CommentModel>> getComments(
      {required String postId, required int page}) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await dio.get(
      '/posts/$postId/comments',
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Usa o factory do PaginatedResponse para desserializar a resposta completa,
    // passando a função de conversão para o CommentModel.
    return PaginatedResponse.fromJson(response.data, CommentModel.fromJson);
  }

  @override
  Future<PaginatedResponse<PostModel>> getMyPosts({required int page}) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await dio.get(
      '/posts/me',
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Reutiliza a mesma lógica de desserialização do getPosts
    return PaginatedResponse.fromJson(response.data, PostModel.fromJson);
  }
}
