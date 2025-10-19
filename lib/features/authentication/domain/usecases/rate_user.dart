import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class RateUser {
  final AuthRepository repository;

  RateUser(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required int rate,
    required String message,
  }) async {
    return await repository.rateUser(
      userId: userId,
      rate: rate,
      message: message,
    );
  }
}
