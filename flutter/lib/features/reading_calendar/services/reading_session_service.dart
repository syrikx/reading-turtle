import 'package:dio/dio.dart';
import '../../../core/utils/api_client.dart';
import '../../../models/reading_session.dart';
import '../../../models/reading_history.dart';

class ReadingSessionService {
  final ApiClient _apiClient;

  ReadingSessionService(this._apiClient);

  /// Get all reading history for calendar
  Future<List<ReadingHistory>> getAllReadingHistory() async {
    try {
      final response = await _apiClient.get('/api/reading/calendar');

      if (response.data['success'] == true) {
        final history = (response.data['history'] as List)
            .map((json) => ReadingHistory.fromJson(json))
            .toList();
        return history;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load history');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get reading sessions for a specific month
  Future<List<ReadingSession>> getMonthSessions(int year, int month) async {
    try {
      final response = await _apiClient.get(
        '/api/reading/calendar',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      if (response.data['success'] == true) {
        // The API returns sessions grouped by date
        final sessionsData = response.data['sessions'] as List? ?? [];
        final sessions = sessionsData
            .map((json) => ReadingSession.fromJson(json))
            .toList();
        return sessions;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sessions');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get sessions for a specific date
  Future<List<ReadingSession>> getDateSessions(String date) async {
    try {
      final response = await _apiClient.get(
        '/api/reading/calendar/date/$date',
      );

      if (response.data['success'] == true) {
        final sessions = (response.data['sessions'] as List)
            .map((json) => ReadingSession.fromJson(json))
            .toList();
        return sessions;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sessions');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Add or update a reading session
  Future<ReadingSession> saveSession(ReadingSessionRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/reading/session',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return ReadingSession.fromJson(response.data['session']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to save session');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete a reading session
  Future<void> deleteSession(int sessionId) async {
    try {
      final response = await _apiClient.delete(
        '/api/reading/session/$sessionId',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete session');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
