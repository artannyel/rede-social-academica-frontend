import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PostRemoteDataSource {
  Future<void> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<File>? images,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  PostRemoteDataSourceImpl({required this.dio, required this.firebaseAuth});

  @override
  Future<void> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<File>? images,
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
        formData.files.add(
          MapEntry('images[]', await MultipartFile.fromFile(images[i].path)),
        );
      }
    }

    await dio.post(
      '/posts',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
