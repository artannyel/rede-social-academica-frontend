import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<User> call({required String name, required String email, required String password}) {
    return repository.register(name: name, email: email, password: password);
  }
}
