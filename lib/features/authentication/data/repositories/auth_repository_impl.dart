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
  Future<User> login({required String email, required String password}) async {
    try {
      // O datasource retorna um UserModel, que é então retornado como uma entidade User.
      // A camada de apresentação nunca verá o UserModel.
      final userModel = await remoteDataSource.login(email: email, password: password);
      return userModel;
    } on firebase.FirebaseAuthException catch (e) {
      // Mapeia os erros do Firebase para nossas falhas de domínio.
      // Por segurança, unificamos 'user-not-found' e 'wrong-password' na mesma mensagem.
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const InvalidCredentialsFailure();
      }
      // Para outros erros inesperados do Firebase.
      throw ServerFailure('Ocorreu um erro durante o login: ${e.code}');
    } on DioException {
      // Erro de comunicação com sua API.
      throw const ServerFailure('Não foi possível conectar ao servidor. Verifique sua internet.');
    }
  }

  @override
  Future<User> register({required String name, required String email, required String password}) async {
    try {
      final userModel = await remoteDataSource.register(name: name, email: email, password: password);
      return userModel;
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw const WeakPasswordFailure();
      } else if (e.code == 'email-already-in-use') {
        throw const EmailAlreadyInUseFailure();
      }
      throw ServerFailure('Ocorreu um erro durante o cadastro: ${e.code}');
    } on DioException {
      throw const ServerFailure('Não foi possível conectar ao servidor. Verifique sua internet.');
    }
  }
}
