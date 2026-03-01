import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Manages authentication state across the app.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ─── Initialize ──────────────────────────────────────────────────────────────

  /// Called on app start to seed users and restore session.
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.seedDefaultUsers();
    final user = await _authService.getSessionUser();

    if (user != null) {
      _currentUser = user;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ─── Login ───────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final user = await _authService.login(email, password);
    if (user != null) {
      _currentUser = user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid email or password.';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
