import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void bypassLogin() {
    // Implement bypass login logic if needed
  }
}
