import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';
import 'package:social_academic/app/core/error/failure.dart';

enum RegisterState { idle, loading, success, error }

class RegisterChangeNotifier extends ChangeNotifier {
  final Register _registerUseCase;

  RegisterChangeNotifier(this._registerUseCase);

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
  }) async {
    _state = RegisterState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final registeredUser = await _registerUseCase(
        name: name,
        email: email,
        password: password,
      );
      _user = registeredUser;
      _state = RegisterState.success;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = RegisterState.error;
    } catch (e) {
      _errorMessage = 'Um erro inesperado ocorreu. Tente novamente mais tarde.';
      _state = RegisterState.error;
    } finally {
      notifyListeners();
    }
  }
}
