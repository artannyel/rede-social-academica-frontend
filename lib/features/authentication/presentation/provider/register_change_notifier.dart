import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/register.dart';

enum RegisterState { idle, loading, success, error }

class RegisterChangeNotifier extends ChangeNotifier {
  final Register _registerUseCase;
  final UserNotifier _userNotifier;

  RegisterChangeNotifier(this._registerUseCase, this._userNotifier);

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
  }) async {
    _state = RegisterState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
      userCourses: userCourses,
      bio: bio,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = RegisterState.error;
      },
      (user) {
        _user = user;
        _state = RegisterState.success;
        _userNotifier.setAppUser(user); // Atualiza o UserNotifier com o usuário completo
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
