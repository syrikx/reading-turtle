import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/book.dart';

part 'quiz_state.freezed.dart';

@freezed
class QuizState with _$QuizState {
  const factory QuizState({
    @Default(false) bool isLoading,
    Book? book,
    @Default([]) List<Quiz> quizzes,
    String? error,
    @Default({}) Map<int, int> userAnswers, // questionId -> selectedChoice
  }) = _QuizState;
}
