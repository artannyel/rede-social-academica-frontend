import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/domain/entities/user.dart';
import 'package:social_academic/features/authentication/domain/usecases/get_current_user.dart';

/// Gerencia o estado do usuário da aplicação (vindo do seu backend).
class UserNotifier extends ChangeNotifier {
  final GetCurrentUser _getCurrentUser;

  UserNotifier(this._getCurrentUser);

  User? _appUser;
  User? get appUser => _appUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Carrega os dados do usuário logado a partir do backend.
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getCurrentUser();
    result.fold(
      (failure) {
        _appUser = null;
        // TODO: Logar a falha
      },
      (user) => _appUser = user,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Define o usuário da aplicação, geralmente após login ou registro.
  void setAppUser(User user) {
    _appUser = user;
    notifyListeners();
  }

  /// Limpa os dados do usuário, geralmente no logout.
  void clearUser() {
    _appUser = null;
    notifyListeners();
  }
}