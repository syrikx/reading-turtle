import '../../core/constants/storage_keys.dart';
import '../../core/utils/api_client.dart';
import '../../core/utils/storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/auth_api_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  late final AuthApiService _authApiService;

  AuthRepositoryImpl(this._apiClient, this._storageService) {
    _authApiService = AuthApiService(_apiClient);
  }

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await _authApiService.login(username, password);

      // Extract token and user data
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      // Save token and user info
      await _storageService.saveString(StorageKeys.jwtToken, token);
      await _storageService.saveString(StorageKeys.userId, userModel.userId);
      await _storageService.saveString(StorageKeys.username, userModel.username);
      await _storageService.saveString(StorageKeys.userEmail, userModel.email);
      if (userModel.fullName != null) {
        await _storageService.saveString(StorageKeys.userFullName, userModel.fullName!);
      }

      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> signup(String username, String email, String password, String fullName) async {
    try {
      final response = await _authApiService.signup(username, email, password, fullName);

      // Extract token and user data
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      // Save token and user info
      await _storageService.saveString(StorageKeys.jwtToken, token);
      await _storageService.saveString(StorageKeys.userId, userModel.userId);
      await _storageService.saveString(StorageKeys.username, userModel.username);
      await _storageService.saveString(StorageKeys.userEmail, userModel.email);
      if (userModel.fullName != null) {
        await _storageService.saveString(StorageKeys.userFullName, userModel.fullName!);
      }

      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clear();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = _storageService.getString(StorageKeys.jwtToken);

    if (token == null) {
      return null;
    }

    final userId = _storageService.getString(StorageKeys.userId);
    final username = _storageService.getString(StorageKeys.username);
    final userEmail = _storageService.getString(StorageKeys.userEmail);
    final userFullName = _storageService.getString(StorageKeys.userFullName);

    if (userId == null || username == null || userEmail == null) {
      return null;
    }

    return User(
      id: userId,
      username: username,
      email: userEmail,
      fullName: userFullName,
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = _storageService.getString(StorageKeys.jwtToken);
    return token != null;
  }
}
