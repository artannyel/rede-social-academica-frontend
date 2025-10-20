import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/app/core/usecases/usecase.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

/// Caso de uso para enviar um e-mail de redefinição de senha.
class SendPasswordResetEmail implements UseCase<void, String> {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) {
    return repository.sendPasswordResetEmail(email: email);
  }
}
