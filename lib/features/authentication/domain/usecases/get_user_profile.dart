import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/authentication/domain/entities/user_profile.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class GetUserProfile implements UseCase<UserProfile, GetUserProfileParams> {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(GetUserProfileParams params) {
    return repository.getUserProfile(userId: params.userId, page: params.page);
  }
}

class GetUserProfileParams extends Equatable {
  final String userId;
  final int page;

  const GetUserProfileParams({required this.userId, required this.page});

  @override
  List<Object?> get props => [userId, page];
}
