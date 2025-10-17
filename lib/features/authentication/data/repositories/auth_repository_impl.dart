import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/error/failure.dart';
import 'package:social_academic/features/authentication/domain/entities/user_profile.dart';
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
    XFile? photo,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        bio: bio,
        userCourses: userCourses,
        photo: photo,
      );
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return const Left(WeakPasswordFailure());
      } else if (e.code == 'email-already-in-use') {
        return const Left(EmailAlreadyInUseFailure());
      } else if (e.code == 'backend-registration-failed') {
        // Trata a falha de registro no nosso backend.
        return Left(
          ServerFailure(e.message ?? 'Falha ao registrar no servidor.'),
        );
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
  Future<Either<Failure, User>> updateUser({
    required String name,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
    XFile? photo,
    bool removePhoto = false,
  }) async {
    try {
      final userModel = await remoteDataSource.updateUser(
        name: name,
        bio: bio,
        userCourses: userCourses,
        photo: photo,
        removePhoto: removePhoto,
      );
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      // Erros relacionados ao Firebase, se houver (ex: reautenticação necessária)
      return Left(ServerFailure('Erro de autenticação: ${e.code}'));
    } on DioException {
      return const Left(
        ServerFailure(
          'Não foi possível conectar ao servidor. Verifique sua internet.',
        ),
      );
    } on Exception catch (e) {
      // Captura a exceção genérica lançada pelo datasource
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
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
        return const Left(
          ServerFailure('Nenhuma conta encontrada para este e-mail.'),
        );
      }
      return Left(
        ServerFailure('Ocorreu um erro ao enviar o e-mail: ${e.message}'),
      );
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
      return Left(
        ServerFailure(
          'Ocorreu um erro inesperado ao buscar o usuário: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile({
    required String userId,
    required int page,
  }) async {
    try {
      // 1. O DataSource agora retorna o modelo de dados já parseado.
      final userProfileModel = await remoteDataSource.getUserProfile(
        userId: userId,
        page: page,
      );

      // 2. O repositório apenas converte o Model para a Entity do domínio.
      return Right(userProfileModel.toEntity());
    } on firebase.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar perfil.'));
    } on DioException {
      return const Left(ServerFailure('Não foi possível carregar o perfil. Verifique sua conexão.'));
    }
    catch (e) {
      return Left(
        ServerFailure(
          'Ocorreu um erro inesperado ao buscar o perfil: ${e.toString()}',
        ),
      );
    }
  }
}
