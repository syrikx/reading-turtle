import '../../core/utils/api_client.dart';
import '../../domain/entities/word.dart';
import '../models/word_model.dart';

class WordApiService {
  final ApiClient _apiClient;

  WordApiService(this._apiClient);

  Future<WordListResponse> getWords(String isbn) async {
    try {
      // IMPORTANT: 반드시 /api/ prefix 포함
      final response = await _apiClient.get('/api/books/$isbn/words');

      final data = response.data;
      if (data['success'] == true) {
        final responseData = data['data'] as Map<String, dynamic>;
        final wordsData = responseData['words'] as List<dynamic>;

        final words = wordsData
            .map((wordJson) => WordModel.fromJson(wordJson as Map<String, dynamic>).toEntity())
            .toList();

        return WordListResponse(
          isbn: responseData['isbn'] as String,
          wordCount: responseData['word_count'] as int,
          words: words,
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to load words');
      }
    } catch (e) {
      throw Exception('Failed to load words: $e');
    }
  }
}
