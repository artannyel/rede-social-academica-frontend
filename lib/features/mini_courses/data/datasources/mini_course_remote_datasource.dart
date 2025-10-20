import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:social_academic/app/core/utils/image_converter.dart';
import 'package:social_academic/app/core/data/models/paginated_response.dart';
import 'package:social_academic/features/mini_courses/data/models/mini_course_model.dart';

abstract class MiniCourseRemoteDataSource {
  Future<MiniCourseModel> createMiniCourse({
    required String title,
    required String description,
    XFile? photo,
    required List<String> courses,
  });

  Future<PaginatedResponse<MiniCourseModel>> getMiniCourses({required int page});
}

class MiniCourseRemoteDataSourceImpl implements MiniCourseRemoteDataSource {
  final Dio dio;
  final firebase.FirebaseAuth firebaseAuth;

  MiniCourseRemoteDataSourceImpl({required this.dio, required this.firebaseAuth});

  @override
  Future<MiniCourseModel> createMiniCourse({
    required String title,
    required String description,
    XFile? photo,
    required List<String> courses,
  }) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) {
      throw Exception('Usuário não autenticado para criar mini curso.');
    }

    dynamic requestData;

    if (photo != null) {
      final formData = FormData();
      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('description', description));
      courses.forEach((courseId) => formData.fields.add(MapEntry('courses[]', courseId)));

      final processedImage = await processAndConvertImage(photo);
      final bytes = Uint8List.fromList(processedImage['bytes'] as List<int>);
      final fileName = processedImage['name'] as String;
      final mimeType = lookupMimeType(fileName, headerBytes: bytes);

      formData.files.add(
        MapEntry(
          'photo',
          MultipartFile.fromBytes(bytes,
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null),
        ),
      );
      requestData = formData;
    } else {
      requestData = {
        'title': title,
        'description': description,
        'courses': courses,
      };
    }

    final response = await dio.post(
      '/mini-courses',
      data: requestData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return MiniCourseModel.fromJson(response.data);
  }

  @override
  Future<PaginatedResponse<MiniCourseModel>> getMiniCourses({required int page}) async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) {
      throw Exception('Usuário não autenticado para listar mini cursos.');
    }

    final response = await dio.get(
      '/mini-courses',
      queryParameters: {'page': page},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return PaginatedResponse.fromJson(response.data, MiniCourseModel.fromJson);
  }
}