import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/repositories/auth_repository.dart';

/// Caso de uso para enviar um e-mail de redefinição de senha.
class SendPasswordResetEmail {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  Future<Either<Failure, void>> call({required String email}) {
    return repository.sendPasswordResetEmail(email: email);
  }
}