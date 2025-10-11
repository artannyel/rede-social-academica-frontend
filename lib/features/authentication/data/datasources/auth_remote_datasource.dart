import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:dio/dio.dart'; // Exemplo com Dio para API
import 'package:flutter/material.dart';
import '../models/user_model.dart';

// Contrato para a fonte de dados remota
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String name, required String email, required String password});
}

// Implementação que usa Firebase Auth e uma API REST (com Dio)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final Dio dio; // Cliente HTTP para sua API

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.dio});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    // 1. Autentica com Firebase
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Pega o token do Firebase
    final token = await userCredential.user?.getIdToken();

    // 3. Busca os dados do usuário na sua API com o token
    final response = await dio.get(
      '/user/me', // Exemplo de endpoint
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    // 1. Cria o usuário no Firebase Auth
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUid = userCredential.user!.uid;

    // 2. Envia os dados para sua API para criar o registro no seu banco
    final response = await dio.post(
      '/user/register', // Exemplo de endpoint
      data: {
        'name': name,
        'email': email,
        'firebase_uid': firebaseUid,
      },
    );

    debugPrint(response.data.toString());

    return UserModel.fromJson(response.data);
  }
}
