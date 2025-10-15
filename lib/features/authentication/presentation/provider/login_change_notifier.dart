import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/login.dart';
import 'package:social_academic/features/authentication/domain/usecases/send_password_reset_email.dart';

enum LoginState { idle, loading, success, error }

class LoginChangeNotifier extends ChangeNotifier {
  final Login _loginUseCase;
  final SendPasswordResetEmail _sendPasswordResetEmailUseCase;
  final UserNotifier _userNotifier;

  LoginChangeNotifier(
    this._loginUseCase,
    this._sendPasswordResetEmailUseCase,
    this._userNotifier,
  );

  LoginState _state = LoginState.idle;
  LoginState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _state = LoginState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) { // Lado Esquerdo (Erro)
        _errorMessage = failure.message;
        _state = LoginState.error;
      },
      (user) { // Lado Direito (Sucesso)
        _user = user;
        _userNotifier.setAppUser(user); // Atualiza o UserNotifier com o usuário completo
        _state = LoginState.success;
      },
    );

    notifyListeners();
  }

  /// Reseta o estado para o valor inicial, evitando que ações sejam repetidas.
  void resetState() {
    _state = LoginState.idle;
    _errorMessage = null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Envia um e-mail de redefinição de senha e retorna uma mensagem de sucesso ou erro.
  Future<String> sendPasswordResetEmail(String email) async {
    final result = await _sendPasswordResetEmailUseCase(email: email);
    return result.fold(
      (failure) => failure.message,
      (_) => 'E-mail de redefinição de senha enviado com sucesso!',
    );
  }
}