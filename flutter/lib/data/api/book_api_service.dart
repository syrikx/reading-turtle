import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_client.dart';

class BookApiService {
  final ApiClient _apiClient;

  BookApiService(this._apiClient);

  /// Search books with query and optional filters
  Future<Map<String, dynamic>> searchBooks({
    required String query,
    String searchType = 'all', // all, isbn, title, author, series
    double? btLevelMin,
    double? btLevelMax,
    int? lexileMin,
    int? lexileMax,
    String? genre, // fiction, nonfiction
    bool? hasQuiz,
    bool? hasWords,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'type': searchType,
      };

      if (btLevelMin != null) queryParams['btLevelMin'] = btLevelMin;
      if (btLevelMax != null) queryParams['btLevelMax'] = btLevelMax;
      if (lexileMin != null) queryParams['lexileMin'] = lexileMin;
      if (lexileMax != null) queryParams['lexileMax'] = lexileMax;
      if (genre != null && genre != 'all') queryParams['genre'] = genre;
      if (hasQuiz == true) queryParams['hasQuiz'] = true;
      if (hasWords == true) queryParams['hasWords'] = true;

      final response = await _apiClient.get(
        ApiConfig.searchBooksEndpoint,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;

      // Check if response has success field
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Book search failed');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid search parameters';
        throw Exception(message);
      }
      throw Exception('Book search failed: ${e.message}');
    }
  }

  /// Get count of books matching search criteria
  Future<int> searchBooksCount({
    String? query,
    String searchType = 'all',
    double? btLevelMin,
    double? btLevelMax,
    int? lexileMin,
    int? lexileMax,
    String? genre,
    bool? hasQuiz,
    bool? hasWords,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      // Use filter-count endpoint if no query, search-count if query exists
      final endpoint = (query == null || query.trim().isEmpty)
          ? '/api/books/filter-count'
          : '/api/books/search-count';

      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query;
        queryParams['type'] = searchType;
      }

      if (btLevelMin != null) queryParams['btLevelMin'] = btLevelMin;
      if (btLevelMax != null) queryParams['btLevelMax'] = btLevelMax;
      if (lexileMin != null) queryParams['lexileMin'] = lexileMin;
      if (lexileMax != null) queryParams['lexileMax'] = lexileMax;
      if (genre != null && genre != 'all') queryParams['genre'] = genre;
      if (hasQuiz == true) queryParams['hasQuiz'] = true;
      if (hasWords == true) queryParams['hasWords'] = true;

      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Count search failed');
      }

      return data['count'] as int;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid search parameters';
        throw Exception(message);
      }
      throw Exception('Count search failed: ${e.message}');
    }
  }

  /// Get book by ISBN
  Future<Map<String, dynamic>> getBookByIsbn(String isbn) async {
    try {
      final response = await _apiClient.get('/api/books/$isbn');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Book not found');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Book not found');
      }
      throw Exception('Failed to get book: ${e.message}');
    }
  }
}
