import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<void> login({
    required String email,
    required String password,
    required bool isDietitian,
  }) async {
    _currentUser = await _authService.login(email, password, isDietitian);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
