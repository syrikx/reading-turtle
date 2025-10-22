import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/quiz_api_service.dart';
import '../../core/utils/api_client.dart';
import 'auth_provider.dart';
import 'quiz_state.dart';

class QuizNotifier extends StateNotifier<QuizState> {
  final QuizApiService _apiService;

  QuizNotifier(this._apiService) : super(const QuizState());

  Future<void> loadQuizzes(String isbn) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getQuizzes(isbn);
      state = state.copyWith(
        isLoading: false,
        book: response.book,
        quizzes: response.quizzes,
        userAnswers: {}, // Reset answers when loading new quizzes
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void answerQuestion(int questionId, int selectedChoice) {
    final newAnswers = {...state.userAnswers, questionId: selectedChoice};
    state = state.copyWith(userAnswers: newAnswers);
  }

  void clearQuizzes() {
    state = const QuizState();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final apiClient = ApiClient(storageService);
  final quizApiService = QuizApiService(apiClient);
  return QuizNotifier(quizApiService);
});
