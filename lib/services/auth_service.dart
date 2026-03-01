import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

/// Handles authentication: login, logout, session persistence.
class AuthService {
  static const String _sessionKey = 'logged_in_user_id';

  final StorageService _storage = StorageService.instance;

  // ─── Default Seed Users ──────────────────────────────────────────────────────

  /// Seeds default admin & staff users on first run.
  Future<void> seedDefaultUsers() async {
    final existing = await _storage.readList(StorageFiles.users);
    if (existing.isNotEmpty) return;

    final defaultUsers = [
      UserModel(
        id: 'U001',
        name: 'Admin User',
        email: 'admin@catering.com',
        password: 'admin123',
        role: 'admin',
      ),
      UserModel(
        id: 'U002',
        name: 'Staff User',
        email: 'staff@catering.com',
        password: 'staff123',
        role: 'staff',
      ),
    ];

    await _storage.writeList(
      StorageFiles.users,
      defaultUsers.map((u) => u.toJson()).toList(),
    );
  }

  // ─── Login ───────────────────────────────────────────────────────────────────

  /// Returns the [UserModel] on successful login, null otherwise.
  Future<UserModel?> login(String email, String password) async {
    final list = await _storage.readList(StorageFiles.users);
    final users = list.map((e) => UserModel.fromJson(e)).toList();

    try {
      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.trim().toLowerCase() &&
            u.password == password &&
            u.isActive,
      );
      // Persist session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, user.id);
      return user;
    } catch (_) {
      return null;
    }
  }

  // ─── Session ─────────────────────────────────────────────────────────────────

  /// Returns the currently logged-in [UserModel] from session, or null.
  Future<UserModel?> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionKey);
    if (userId == null) return null;

    final list = await _storage.readList(StorageFiles.users);
    final users = list.map((e) => UserModel.fromJson(e)).toList();
    try {
      return users.firstWhere((u) => u.id == userId && u.isActive);
    } catch (_) {
      return null;
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
