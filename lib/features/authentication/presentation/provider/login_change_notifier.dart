import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/login.dart';
import 'package:social_academic/app/core/error/failure.dart';

enum LoginState { idle, loading, success, error }

class LoginChangeNotifier extends ChangeNotifier {
  final Login _loginUseCase;

  LoginChangeNotifier(this._loginUseCase);

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

    try {
      final loggedInUser = await _loginUseCase(
        email: email,
        password: password,
      );
      _user = loggedInUser;
      _state = LoginState.success;
    } on Failure catch (e) {
      _errorMessage = e.message; // Usa a mensagem da nossa falha personalizada!
      _state = LoginState.error;
    } catch (e) {
      _errorMessage = 'Um erro inesperado ocorreu. Tente novamente mais tarde.';
      _state = LoginState.error;
    } finally {
      notifyListeners();
    }
  }
}