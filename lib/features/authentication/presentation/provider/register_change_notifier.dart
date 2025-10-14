import 'package:flutter/material.dart';
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';

enum RegisterState { idle, loading, success, error }

class RegisterChangeNotifier extends ChangeNotifier {
  final Register _registerUseCase;
  final AuthNotifier _authNotifier;

  RegisterChangeNotifier(this._registerUseCase, this._authNotifier);

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
  }) async {
    // Pausa o listener global para evitar o redirecionamento prematuro.
    _authNotifier.pauseListener();

    _state = RegisterState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
      userCourses: userCourses,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = RegisterState.error;
        // Em caso de erro, apenas reativamos o listener sem notificar,
        // para que o app possa reagir a outras ações (como um logout manual),
        // mas sem causar um redirecionamento.
        _authNotifier.resumeListener(notify: false);
      },
      (user) {
        _user = user;
        _state = RegisterState.success;
        // Em caso de sucesso, reativamos o listener e notificamos,
        // para que o GoRouter possa redirecionar para a tela de verificação.
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
