import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';

class AuthNotifier extends ChangeNotifier {
  final firebase.FirebaseAuth _auth;
  final UserNotifier _userNotifier;
  StreamSubscription<firebase.User?>? _authStateSubscription;
 
  firebase.User? _user;
  firebase.User? get user => _user;
 
  AuthNotifier(this._auth, this._userNotifier) {
    // Inicia a escuta do estado de autenticação do Firebase
    _listenToAuthStateChanges();
  }

  void _listenToAuthStateChanges() {
    _authStateSubscription = _auth.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;
      // Notifica o GoRouter sobre a mudança no estado de autenticação.
      notifyListeners();

      if (_user == null) {
        // Se o usuário do Firebase for nulo (logout), limpa os dados no UserNotifier.
        _userNotifier.clearUser();
      } else {
        // Se há um usuário no Firebase, comanda o UserNotifier para carregar os dados.
        await _userNotifier.loadCurrentUser();
      }
    });
  }

  Future<void> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    notifyListeners(); // Apenas notifica para o GoRouter reavaliar.
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
