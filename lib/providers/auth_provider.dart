import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.currentUser != null;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.registerUser(
      name: name,
      email: email,
      password: password,
    );

    _isLoading = false;
    notifyListeners();
    return error; // null = success, otherwise error message
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.loginUser(email: email, password: password);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
