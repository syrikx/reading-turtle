import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_client.dart';
import '../models/user_model.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Check if response has success field
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['message'] ?? 'Invalid username or password';
        throw Exception(message);
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Signup with username, email, password, and fullName
  Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.signupEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Check if response has success field
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Signup failed');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        final message = e.response?.data['message'] ?? 'Username or email already exists';
        throw Exception(message);
      }
      throw Exception('Signup failed: ${e.message}');
    }
  }
}
