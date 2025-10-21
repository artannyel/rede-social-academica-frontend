import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart' as domain;
import 'package:social_academic/features/mini_courses/data/datasources/mini_course_remote_datasource.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/repositories/mini_course_repository.dart';

class MiniCourseRepositoryImpl implements MiniCourseRepository {
  final MiniCourseRemoteDataSource remoteDataSource;

  MiniCourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MiniCourse>> createMiniCourse({
    required String title,
    required String description,
    XFile? photo,
    required List<String> courses,
  }) async {
    try {
      final miniCourseModel = await remoteDataSource.createMiniCourse(
        title: title,
        description: description,
        photo: photo,
        courses: courses,
      );
      return Right(miniCourseModel.toEntity());
    } on DioException catch (e) {
      String errorMessage = 'Não foi possível criar o mini curso.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, domain.PaginatedResponse<MiniCourse>>> getMiniCourses({required int page}) async {
    try {
      final paginatedResponse = await remoteDataSource.getMiniCourses(page: page);
      return Right(paginatedResponse.toEntity<MiniCourse>());
    } on DioException {
      return const Left(
        ServerFailure('Não foi possível carregar os mini cursos. Verifique sua conexão.'),
      );
    } on Exception catch (e) {
      return Left(
        ServerFailure(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, domain.PaginatedResponse<MiniCourse>>> getMyMiniCourses({required int page}) async {
    try {
      final paginatedResponse = await remoteDataSource.getMyMiniCourses(page: page);
      return Right(paginatedResponse.toEntity<MiniCourse>());
    } on DioException {
      return const Left(
        ServerFailure('Não foi possível carregar seus mini cursos. Verifique sua conexão.'),
      );
    } on Exception catch (e) {
      return Left(
        ServerFailure(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }
}