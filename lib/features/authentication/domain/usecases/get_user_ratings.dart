import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class GetUserRatings {
  final AuthRepository repository;

  GetUserRatings(this.repository);

  Future<Either<Failure, PaginatedResponse<UserRating>>> call({
    required String userId,
    required int page,
  }) {
    return repository.getUserRatings(userId: userId, page: page);
  }
}