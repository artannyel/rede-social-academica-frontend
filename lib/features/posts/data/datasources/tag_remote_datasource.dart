import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:social_academic/features/posts/data/models/tag_model.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> getTags();
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  TagRemoteDataSourceImpl({required this.dio, required this.firebaseAuth});

  @override
  Future<List<TagModel>> getTags() async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await dio.get(
      '/tags',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    debugPrint(response.data.toString());

    final tagsData = response.data as List;
    return tagsData.map((tagJson) => TagModel.fromJson(tagJson)).toList();
  }
}
