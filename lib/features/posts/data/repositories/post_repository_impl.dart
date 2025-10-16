import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/data/models/paginated_response.dart'
    as data_paginated;
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:social_academic/features/posts/domain/entities/comment.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/data/models/post_model.dart';
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
      await remoteDataSource.createPost(
        publication: publication,
        tags: tags,
        courses: courses,
        images: images,
      );
      return const Right(null);
    } on DioException catch (e) {
      String errorMessage =
          'Não foi possível criar a publicação. Verifique sua conexão.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<Post>>> getPosts({
    required int page,
  }) async {
    try {
      final paginatedModel = await remoteDataSource.getPosts(page: page);
      // Converte o PaginatedResponse<PostModel> para PaginatedResponse<Post> (entidade)
      final paginatedEntity = _convertFromDataResponse(paginatedModel);
      return Right(paginatedEntity);
    } on DioException catch (e) {
      // Adiciona um log para facilitar a depuração de erros da API.
      log('DioException in getPosts: ${e.response?.data}');
      String errorMessage =
          'Não foi possível buscar as publicações. Verifique sua conexão.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e, stackTrace) {
      log('Unexpected error in getPosts', error: e, stackTrace: stackTrace);
      return Left(
        ServerFailure(
          'Ocorreu um erro inesperado ao buscar as publicações: ${e.toString()}',
        ),
      );
    }
  }

  // Método auxiliar para converter o modelo de dados para a entidade de domínio.
  PaginatedResponse<Post> _convertFromDataResponse(
    data_paginated.PaginatedResponse<PostModel> paginatedModel,
  ) {
    return PaginatedResponse(
      currentPage: paginatedModel.currentPage,
      data: paginatedModel
          .data, // A lista de PostModel é compatível com List<Post>
      lastPage: paginatedModel.lastPage,
      total: paginatedModel.total,
    );
  }

  @override
  Future<Either<Failure, void>> likePost({required String postId}) async {
    try {
      await remoteDataSource.likePost(postId: postId);
      return const Right(null);
    } on DioException catch (e) {
      log('DioException in likePost: ${e.response?.data}');
      String errorMessage = 'Não foi possível processar sua curtida.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> likeComment({required String commentId}) async {
    try {
      await remoteDataSource.likeComment(commentId: commentId);
      return const Right(null);
    } on DioException catch (e) {
      log('DioException in likeComment: ${e.response?.data}');
      String errorMessage = 'Não foi possível processar sua curtida.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createComment({
    required String postId,
    required String comment,
    String? parentCommentId,
  }) async {
    try {
      await remoteDataSource.createComment(
        postId: postId,
        comment: comment,
        parentCommentId: parentCommentId,
      );
      return const Right(null);
    } on DioException catch (e) {
      log('DioException in createComment: ${e.response?.data}');
      String errorMessage = 'Não foi possível enviar seu comentário.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<Comment>>> getComments(
      {required String postId, required int page}) async {
    try {
      final paginatedModel =
          await remoteDataSource.getComments(postId: postId, page: page);
      // Converte o PaginatedResponse<CommentModel> para PaginatedResponse<Comment> (entidade)
      return Right(
        PaginatedResponse<Comment>(
          currentPage: paginatedModel.currentPage,
          data: paginatedModel.data,
          lastPage: paginatedModel.lastPage,
          total: paginatedModel.total,
        ),
      );
    } on DioException catch (e) {
      log('DioException in getComments: ${e.response?.data}');
      String errorMessage = 'Não foi possível buscar os comentários.';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e, stackTrace) {
      log('Unexpected error in getComments',
          error: e, stackTrace: stackTrace);
      return Left(ServerFailure(
          'Ocorreu um erro inesperado ao buscar os comentários: ${e.toString()}'));
    }
  }
}
