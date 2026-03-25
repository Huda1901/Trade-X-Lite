import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _userName = '';
  String _userEmail = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _userName;
  String get userEmail => _userEmail;

  // ── Mock Login ───────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock credentials check
    if (email == 'trader@tradexlite.com' && password == 'Trade@123') {
      _isAuthenticated = true;
      _userName = 'Alex Morgan';
      _userEmail = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────
  void logout() {
    _isAuthenticated = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }
}
