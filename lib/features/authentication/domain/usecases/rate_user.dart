import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

class RateUser implements UseCase<void, RateUserParams> {
  final AuthRepository repository;

  RateUser(this.repository);

  @override
  Future<Either<Failure, void>> call(RateUserParams params) async {
    return await repository.rateUser(
      userId: params.userId,
      rate: params.rate,
      message: params.message,
    );
  }
}

class RateUserParams extends Equatable {
  final String userId;
  final int rate;
  final String message;

  const RateUserParams({
    required this.userId,
    required this.rate,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, rate, message];
}
