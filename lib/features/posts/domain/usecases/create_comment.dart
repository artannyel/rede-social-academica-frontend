import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/posts/domain/repositories/post_repository.dart';

/// Caso de uso para criar um novo comentário.
class CreateComment implements UseCase<void, CreateCommentParams> {
  final PostRepository repository;

  CreateComment(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateCommentParams params) {
    return repository.createComment(
      postId: params.postId,
      comment: params.comment,
      parentCommentId: params.parentCommentId,
    );
  }
}

class CreateCommentParams extends Equatable {
  final String postId;
  final String comment;
  final String? parentCommentId;

  const CreateCommentParams({
    required this.postId,
    required this.comment,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, comment, parentCommentId];
}
