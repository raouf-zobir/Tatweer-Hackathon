import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    // Mock authentication - replace with real authentication later
    if (email == 'admin@admin.com' && password == 'admin123') {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void bypassLogin() {
    _isAuthenticated = true;
    notifyListeners();
  }
}
