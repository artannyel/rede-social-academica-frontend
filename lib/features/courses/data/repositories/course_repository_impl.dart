import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Course>>> getCourses() async {
    try {
      final courseModels = await remoteDataSource.getCourses();
      // A implementação do repositório retorna a entidade, não o modelo.
      return Right(courseModels);
    } on DioException catch (e) {
      // Aqui você pode tratar diferentes tipos de erros de rede/servidor.
      return Left(ServerFailure(e.message ?? 'Erro ao buscar cursos'));
    }
  }
}