import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/book.dart';
import '../models/book_model.dart';

class QuizApiService {
  final ApiClient _apiClient;

  QuizApiService(this._apiClient);

  Future<QuizResponse> getQuizzes(String isbn) async {
    try {
      final response = await _apiClient.get('/api/books/$isbn/quizzes');

      final data = response.data;
      if (data['success'] == true) {
        final bookData = data['book'] as Map<String, dynamic>;
        final quizzesData = data['quizzes'] as List<dynamic>;

        final bookModel = BookModel.fromJson(bookData);
        final book = bookModel.toEntity();

        final quizzes = quizzesData
            .map((quizJson) => Quiz.fromJson(quizJson as Map<String, dynamic>))
            .toList();

        return QuizResponse(book: book, quizzes: quizzes);
      } else {
        throw Exception(data['message'] ?? 'Failed to load quizzes');
      }
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  /// Generate quiz by level range
  Future<Map<String, dynamic>> getQuizByLevel({
    required double minLevel,
    required double maxLevel,
    required int count,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/words/quiz',
        queryParameters: {
          'btLevelMin': minLevel,
          'btLevelMax': maxLevel,
          'count': count,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get quiz');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get quiz: ${e.message}');
    }
  }

  /// Generate quiz with user word filters (known/bookmarked/studied)
  Future<Map<String, dynamic>> getQuizByUserWords({
    required String filter,
    required int count,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/quiz/user-words',
        queryParameters: {
          'filter': filter,
          'count': count,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get quiz');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get quiz: ${e.message}');
    }
  }

  /// Generate quiz for wrong answers
  Future<Map<String, dynamic>> getQuizByWrongAnswers({
    required int count,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/quiz/wrong-answers',
        queryParameters: {
          'count': count,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get quiz');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get quiz: ${e.message}');
    }
  }

  /// Record wrong answer
  Future<Map<String, dynamic>> recordWrongAnswer({
    required int wordId,
    required String word,
    String? quizType,
    String? quizFilterValue,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/quiz/wrong-answer',
        data: {
          'word_id': wordId,
          'word': word,
          'quiz_type': quizType,
          'quiz_filter_value': quizFilterValue,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to record wrong answer');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to record wrong answer: ${e.message}');
    }
  }

  /// Get wrong answers list
  Future<Map<String, dynamic>> getWrongAnswersList() async {
    try {
      final response = await _apiClient.get('/api/quiz/wrong-answers/list');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get wrong answers list');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get wrong answers list: ${e.message}');
    }
  }

  /// Delete wrong answer
  Future<Map<String, dynamic>> deleteWrongAnswer({
    required int wordId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/api/quiz/wrong-answer/$wordId',
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to delete wrong answer');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to delete wrong answer: ${e.message}');
    }
  }
}
