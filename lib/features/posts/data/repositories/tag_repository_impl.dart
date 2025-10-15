import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/data/datasources/tag_remote_datasource.dart';
import 'package:social_academic/features/posts/domain/entities/tag.dart';
import 'package:social_academic/features/posts/domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    try {
      final tagModels = await remoteDataSource.getTags();
      return Right(tagModels);
    } on DioException {
      return const Left(
        ServerFailure(
          'Não foi possível buscar as tags. Verifique sua conexão.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }
}