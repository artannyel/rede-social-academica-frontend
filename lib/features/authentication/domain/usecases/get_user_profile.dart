import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/entities/user_profile.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class GetUserProfile {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  Future<Either<Failure, UserProfile>> call(
      {required String userId, required int page}) {
    return repository.getUserProfile(userId: userId, page: page);
  }
}