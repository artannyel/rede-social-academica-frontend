import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  }) async {
    try {
      await remoteDataSource.createPost(publication: publication, tags: tags, courses: courses, images: images);
      return const Right(null);
    } on DioException catch (e) {
      String errorMessage = 'Não foi possível criar a publicação. Verifique sua conexão.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }
}
