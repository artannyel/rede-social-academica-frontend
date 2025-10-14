import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// Um caso de uso representa uma única ação/regra de negócio.
class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
