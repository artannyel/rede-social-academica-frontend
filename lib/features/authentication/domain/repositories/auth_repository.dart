import 'package:dartz/dartz.dart';
import 'package:social_academic/app/core/error/failure.dart';
import '../entities/user.dart';

// Contrato que define as operações de autenticação.
// A camada de apresentação usará esta interface, sem saber da implementação.
abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    List<Map<String, dynamic>>? userCourses,
    String? bio,
  });
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
  Future<Either<Failure, User>> getCurrentUser();
}
