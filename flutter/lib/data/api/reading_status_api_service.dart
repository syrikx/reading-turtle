import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class ReadingStatusApiService {
  final ApiClient _apiClient;

  ReadingStatusApiService(this._apiClient);

  /// Update reading status for a book
  Future<Map<String, dynamic>> updateStatus({
    required String isbn,
    required String status, // reading, completed
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/reading/status',
        data: {
          'isbn': isbn,
          'status': status,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to update status');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to update status: ${e.message}');
    }
  }

  /// Get reading history with optional status filter
  Future<Map<String, dynamic>> getHistory({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        '/api/reading/history',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get history');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get history: ${e.message}');
    }
  }

  /// Get reading statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.get('/api/reading/stats');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get stats');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get stats: ${e.message}');
    }
  }
}
