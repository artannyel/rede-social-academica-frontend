import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authStateSubscription;

  User? _user;
  User? get user => _user;
  bool _isListenerPaused = false;

  AuthNotifier(this._auth) {
    // Inicia a escuta do estado de autenticação do Firebase
    _listenToAuthStateChanges();
  }

  void _listenToAuthStateChanges() {
    _authStateSubscription = _auth.authStateChanges().listen((newUser) {
      if (_isListenerPaused) return;

      _user = newUser;
      notifyListeners();
    });
  }

  /// Pausa o listener de autenticação. Usado durante o processo de registro.
  void pauseListener() {
    _isListenerPaused = true;
  }

  /// Retoma o listener e atualiza o estado do usuário imediatamente.
  void resumeListener({bool notify = true}) {
    _isListenerPaused = false;
    _user = _auth.currentUser;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
