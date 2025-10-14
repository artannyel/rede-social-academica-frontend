import 'package:dio/dio.dart';
import '../models/course_model.dart';

/// Contrato para a fonte de dados remota de Cursos.
abstract class CourseRemoteDataSource {
  /// Busca uma lista de cursos da API.
  Future<List<CourseModel>> getCourses();
}

/// Implementação do DataSource que busca os dados de uma API REST usando Dio.
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio dio;

  CourseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      // Exemplo de chamada para um endpoint que retorna uma lista de cursos.
      // O token de autorização pode ser necessário dependendo da sua API.
      final response = await dio.get('/courses');
      final coursesData = response.data['data'];

      // Converte a lista de JSONs em uma lista de CourseModel.
      final courses = (coursesData as List<dynamic>)
          .map((courseJson) => CourseModel.fromJson(courseJson))
          .toList();

      return courses;
    } catch (e) {
      // Em um caso real, você trataria os erros de forma mais específica.
      rethrow;
    }
  }
}