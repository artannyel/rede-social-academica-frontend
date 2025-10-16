import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/courses/presentation/provider/course_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';

enum RegisterState { idle, loading, success, error }

class RegisterChangeNotifier extends ChangeNotifier {
  final Register _registerUseCase;
  final AuthNotifier _authNotifier;
  final UserNotifier _userNotifier;
  final CourseChangeNotifier _courseNotifier;

  RegisterChangeNotifier(
    this._registerUseCase,
    this._authNotifier,
    this._userNotifier,
    this._courseNotifier,
  );

  RegisterState _state = RegisterState.idle;
  RegisterState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    List<Map<String, dynamic>>? userCourses,
    String? bio,
    XFile? photo,
  }) async {
    _state = RegisterState.loading;
    // Pausa o listener para evitar que o GoRouter redirecione antes da hora.
    _authNotifier.pauseListener();
    _errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
      userCourses: userCourses,
      bio: bio,
      photo: photo,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = RegisterState.error;
        // Em caso de erro, não retomamos o listener. A tela de registro
        // mostrará o erro e o usuário poderá tentar novamente.
      },
      (user) {
        _user = user;
        _state = RegisterState.success;
        _userNotifier.setAppUser(user); // Atualiza o UserNotifier com o usuário completo
        _courseNotifier.clearCourses(); // Limpa os cursos após o registro
        // Retoma o listener APENAS em caso de sucesso para que o fluxo de
        // autenticação (e o GoRouter) continue normalmente.
        _authNotifier.resumeListener();
      },
    );

    notifyListeners();
  }

  /// Reseta o estado para o valor inicial, evitando que ações sejam repetidas.
  void resetState() {
    _state = RegisterState.idle;
    _errorMessage = null;
  }
}
