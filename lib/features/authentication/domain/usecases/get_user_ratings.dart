import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class GetUserRatings
    implements UseCase<PaginatedResponse<UserRating>, GetUserRatingsParams> {
  final AuthRepository repository;

  GetUserRatings(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<UserRating>>> call(
    GetUserRatingsParams params,
  ) {
    return repository.getUserRatings(userId: params.userId, page: params.page);
  }
}

class GetUserRatingsParams extends Equatable {
  final String userId;
  final int page;

  const GetUserRatingsParams({required this.userId, required this.page});

  @override
  List<Object?> get props => [userId, page];
}
