import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart' as domain;
import 'package:social_academic/features/mini_courses/data/datasources/mini_course_remote_datasource.dart';
import 'package:social_academic/features/mini_courses/domain/entities/mini_course.dart';
import 'package:social_academic/features/mini_courses/domain/entities/lesson.dart';
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

  @override
  Future<Either<Failure, void>> enrollMiniCourse({required String miniCourseId}) async {
    try {
      await remoteDataSource.enrollMiniCourse(miniCourseId: miniCourseId);
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Não foi possível se inscrever no curso.';
      return Left(ServerFailure(message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MiniCourse>> getMiniCourseDetail({required String miniCourseId}) async {
    try {
      final miniCourseModel = await remoteDataSource.getMiniCourseDetail(miniCourseId: miniCourseId);
      return Right(miniCourseModel.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Não foi possível carregar os detalhes do curso.';
      return Left(ServerFailure(message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MiniCourse>> publishMiniCourse({required String miniCourseId}) async {
    try {
      final miniCourseModel = await remoteDataSource.publishMiniCourse(miniCourseId: miniCourseId);
      return Right(miniCourseModel.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Não foi possível publicar o curso.';
      return Left(ServerFailure(message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, Lesson>> addLesson({
    required String miniCourseId,
    required String title,
    required String description,
    required String youtubeUrl,
  }) async {
    try {
      final lessonModel = await remoteDataSource.addLesson(
        miniCourseId: miniCourseId,
        title: title,
        description: description,
        youtubeUrl: youtubeUrl,
      );
      return Right(lessonModel.toEntity());
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Não foi possível adicionar a aula.';
      return Left(ServerFailure(message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}