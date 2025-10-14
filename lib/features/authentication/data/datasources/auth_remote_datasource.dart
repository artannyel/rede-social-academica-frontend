import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:dio/dio.dart'; // Exemplo com Dio para API
import '../models/user_model.dart';

// Contrato para a fonte de dados remota
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    List<Map<String, dynamic>>? userCourses,
  });
  Future<void> sendPasswordResetEmail({required String email});
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
    final token = await userCredential.user?.getIdToken();

    // 3. Busca os dados do usuário na sua API com o token
    final response = await dio.get(
      '/user/me', // Exemplo de endpoint
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
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
}
