import '../entities/user.dart';

// Contrato que define as operações de autenticação.
// A camada de apresentação usará esta interface, sem saber da implementação.
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({required String name, required String email, required String password});
}
