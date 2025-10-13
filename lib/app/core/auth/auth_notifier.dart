import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';

class AuthNotifier extends ChangeNotifier {
  final firebase.FirebaseAuth _firebaseAuth;
  late final StreamSubscription<firebase.User?> _authSubscription;

  firebase.User? _user;
  firebase.User? get user => _user;

  AuthNotifier(this._firebaseAuth) {
    _authSubscription = _firebaseAuth.authStateChanges().listen((newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  /// Força a recarga do usuário atual e notifica os ouvintes.
  /// Isso é útil após a verificação de e-mail, pois authStateChanges não dispara.
  Future<void> checkEmailVerification() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      _user = _firebaseAuth.currentUser; // Pega a instância atualizada
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
