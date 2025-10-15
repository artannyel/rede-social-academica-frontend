import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:dio/dio.dart'; // Exemplo com Dio para API
import 'package:flutter/material.dart';
import '../models/user_model.dart';

// Contrato para a fonte de dados remota
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<UserModel> getCurrentUser();
}

// Implementação que usa Firebase Auth e uma API REST (com Dio)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final Dio dio; // Cliente HTTP para sua API

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.dio});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // 1. Autentica com Firebase
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Pega o token do Firebase
    await userCredential.user?.getIdToken();

    // 3. Reutiliza a lógica de buscar o usuário atual
    return await getCurrentUser();
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
  }) async {
    // 1. Cria o usuário no Firebase Auth
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUid = userCredential.user!.uid;

    try {
      // 2. Envia os dados para sua API para criar o registro no seu banco
      final response = await dio.post(
        '/user/register', // Exemplo de endpoint
        data: {
          'name': name,
          'email': email,
          'firebase_uid': firebaseUid,
          'bio': bio,
          'courses': userCourses, // Envia a lista de cursos e semestres
        },
      );
      // Somente se o passo 2 for bem-sucedido, retornamos o usuário.
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      // 3. Se o registro na sua API falhar, deletamos o usuário do Firebase
      // para evitar dados inconsistentes (usuário órfão).
      await userCredential.user?.delete();

      // Tenta extrair uma mensagem de erro específica do corpo da resposta da API.
      String errorMessage =
          'Não foi possível concluir o cadastro. Tente novamente.';
      if (e.response?.data is Map<String, dynamic>) {
        // Assumindo que sua API retorna um JSON com a chave 'message'.
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }

      // Lança a exceção com a mensagem de erro, que será capturada pelo repositório.
      throw firebase.FirebaseAuthException(
        code: 'backend-registration-failed',
        message: errorMessage,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final token = await firebaseAuth.currentUser?.getIdToken();
    if (token == null) {
      throw Exception('Usuário não autenticado para buscar dados.');
    }

    final response = await dio.get(
      '/user/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    debugPrint(response.data.toString());
    return UserModel.fromJson(response.data);
  }
}
