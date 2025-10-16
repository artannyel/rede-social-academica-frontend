import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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
    XFile? photo,
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
    XFile? photo,
  }) async {
    // 1. Cria o usuário no Firebase Auth
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUid = userCredential.user!.uid;

    try {
      // 2. Envia os dados para sua API para criar o registro no seu banco
      dynamic requestData;

      if (photo != null) {
        // Constrói o FormData manualmente para garantir o formato correto dos arrays.
        final formData = FormData();
        formData.fields.add(MapEntry('name', name));
        formData.fields.add(MapEntry('email', email));
        formData.fields.add(MapEntry('firebase_uid', firebaseUid));
        if (bio != null) {
          formData.fields.add(MapEntry('bio', bio));
        }
        // Constrói o array de cursos no formato que o backend (ex: Laravel) espera.
        // Ex: courses[0][id]=uuid, courses[0][current_semester]=1
        if (userCourses != null) {
          for (var i = 0; i < userCourses.length; i++) {
            final courseMap = userCourses[i];
            courseMap.forEach((key, value) {
              if (key == 'finished') {
                // Adiciona cada chave/valor do mapa do curso com o índice correto.
                final el = value == true ? 1 : 0;
                formData.fields.add(
                  MapEntry('courses[$i][$key]', el.toString()),
                );
              } else {
                // Adiciona cada chave/valor do mapa do curso com o índice correto.
                formData.fields.add(
                  MapEntry('courses[$i][$key]', value.toString()),
                );
              }
            });
          }
        }

        // final fileName = photo.path.split('/').last;
        final bytes = await photo.readAsBytes();
        formData.files.add(
          MapEntry(
            'photo',
            MultipartFile.fromBytes(bytes, filename: photo.name),
          ),
        );
        requestData = formData;
      } else {
        // Se não houver foto, envia como um JSON simples.
        requestData = {
          'name': name,
          'email': email,
          'firebase_uid': firebaseUid,
          if (bio != null) 'bio': bio,
          // No JSON, podemos enviar a lista de mapas diretamente.
          if (userCourses != null) 'courses': userCourses,
        };
      }

      final response = await dio.post('/user/register', data: requestData);
      // Assumindo que o usuário está dentro de uma chave 'data' na resposta.
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
    return UserModel.fromJson(response.data);
  }
}
