import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class UserWordApiService {
  final ApiClient _apiClient;

  UserWordApiService(this._apiClient);

  /// Get user's word progress for a specific book
  Future<Map<String, dynamic>> getUserWordProgress({
    required String isbn,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/user-words/progress/$isbn',
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get user word progress');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get user word progress: ${e.message}');
    }
  }

  /// Mark a word as known/unknown
  Future<Map<String, dynamic>> toggleWordKnown({
    required int wordId,
    required bool isKnown,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/user-words/known',
        data: {
          'word_id': wordId,
          'is_known': isKnown,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to update word status');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to update word status: ${e.message}');
    }
  }

  /// Bookmark/unbookmark a word
  Future<Map<String, dynamic>> toggleWordBookmark({
    required int wordId,
    required bool isBookmarked,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/user-words/bookmark',
        data: {
          'word_id': wordId,
          'is_bookmarked': isBookmarked,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to bookmark word');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to bookmark word: ${e.message}');
    }
  }

  /// Record word study (increment study count)
  Future<Map<String, dynamic>> recordWordStudy({
    required int wordId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/user-words/study',
        data: {
          'word_id': wordId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to record study');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to record study: ${e.message}');
    }
  }

  /// Get user's word statistics
  Future<Map<String, dynamic>> getUserWordStats() async {
    try {
      final response = await _apiClient.get('/api/user-words/stats');

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

  /// Get user's bookmarked words
  Future<Map<String, dynamic>> getBookmarkedWords() async {
    try {
      final response = await _apiClient.get('/api/user-words/bookmarked');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get bookmarked words');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get bookmarked words: ${e.message}');
    }
  }

  /// Get all user words with optional filter
  Future<Map<String, dynamic>> getAllUserWords({String? filter}) async {
    try {
      final queryParams = filter != null ? {'filter': filter} : null;
      final response = await _apiClient.get(
        '/api/user-words/all',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get user words');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get user words: ${e.message}');
    }
  }
}
