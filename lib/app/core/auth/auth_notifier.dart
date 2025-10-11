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

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

