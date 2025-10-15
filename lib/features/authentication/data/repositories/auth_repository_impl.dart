import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:social_academic/app/core/error/failure.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// Implementação concreta do repositório.
// Sua principal função é chamar o datasource e tratar erros, convertendo-os
// em falhas que a camada de domínio entende.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // O datasource retorna um UserModel, que é então retornado como uma entidade User.
      // A camada de apresentação nunca verá o UserModel.
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      // Mapeia os erros do Firebase para nossas falhas de domínio.
      // Por segurança, unificamos 'user-not-found' e 'wrong-password' na mesma mensagem.
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return const Left(InvalidCredentialsFailure());
      }
      // Para outros erros inesperados do Firebase.
      return Left(ServerFailure('Ocorreu um erro durante o login: ${e.code}'));
    } on DioException {
      // Erro de comunicação com sua API.
      return const Left(
        ServerFailure(
          'Não foi possível conectar ao servidor. Verifique sua internet.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        bio: bio,
        userCourses: userCourses,
      );
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return const Left(WeakPasswordFailure());
      } else if (e.code == 'email-already-in-use') {
        return const Left(EmailAlreadyInUseFailure());
      } else if (e.code == 'backend-registration-failed') {
        // Trata a falha de registro no nosso backend.
        return Left(ServerFailure(e.message ?? 'Falha ao registrar no servidor.'));
      }
      return Left(
        ServerFailure('Ocorreu um erro durante o cadastro: ${e.code}'),
      );
    } on DioException {
      return const Left(
        ServerFailure(
          'Não foi possível conectar ao servidor. Verifique sua internet.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        return const Left(ServerFailure('Nenhuma conta encontrada para este e-mail.'));
      }
      return Left(ServerFailure(
          'Ocorreu um erro ao enviar o e-mail: ${e.message}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } on DioException {
      return const Left(
        ServerFailure(
          'Não foi possível buscar os dados do usuário. Verifique sua conexão.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado ao buscar o usuário: ${e.toString()}'));
    }
  }
}
