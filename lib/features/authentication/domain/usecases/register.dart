import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String password,
    List<Map<String, dynamic>>? userCourses,
    String? bio,
  }) {
    // A lógica de negócio para associar os cursos seria passada aqui.
    // Por enquanto, apenas repassamos para o repositório.
    return repository.register(
      name: name,
      email: email,
      password: password,
      userCourses: userCourses,
      bio: bio,
    );
  }
}
