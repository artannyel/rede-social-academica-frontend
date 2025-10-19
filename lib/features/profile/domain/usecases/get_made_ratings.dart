import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/domain/entities/paginated_response.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/entities/user_rating.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class GetMadeRatings {
  final AuthRepository repository;

  GetMadeRatings(this.repository);

  Future<Either<Failure, PaginatedResponse<UserRating>>> call({required int page}) {
    return repository.getMadeRatings(page: page);
  }
}