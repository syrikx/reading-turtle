import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/word_api_service.dart';
import '../../core/utils/api_client.dart';
import 'auth_provider.dart';
import 'word_state.dart';

class WordNotifier extends StateNotifier<WordState> {
  final WordApiService _apiService;

  WordNotifier(this._apiService) : super(const WordState());

  Future<void> loadWords(String isbn) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getWords(isbn);
      state = state.copyWith(
        isLoading: false,
        isbn: response.isbn,
        wordCount: response.wordCount,
        words: response.words,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearWords() {
    state = const WordState();
  }
}

final wordProvider = StateNotifierProvider<WordNotifier, WordState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final apiClient = ApiClient(storageService);
  final wordApiService = WordApiService(apiClient);
  return WordNotifier(wordApiService);
});
