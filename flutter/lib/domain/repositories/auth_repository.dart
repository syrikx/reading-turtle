import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with username and password
  /// Returns [User] on success
  /// Throws [Exception] on failure
  Future<User> login(String username, String password);

  /// Signup with username, email, password, and fullName
  /// Returns [User] on success
  /// Throws [Exception] on failure
  Future<User> signup(String username, String email, String password, String fullName);

  /// Logout current user
  Future<void> logout();

  /// Get current logged in user
  /// Returns [User] if logged in, null otherwise
  Future<User?> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
