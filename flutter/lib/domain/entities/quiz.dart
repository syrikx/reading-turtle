import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/book.dart';

part 'quiz.freezed.dart';

@freezed
class Quiz with _$Quiz {
  const factory Quiz({
    required int questionId,
    required int questionNumber,
    required String questionText,
    required String choice1,
    required String choice2,
    required String choice3,
    required String choice4,
    required int correctChoiceNumber,
    required String correctAnswer,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    // Safe parsing for numeric fields that might be strings
    int parseIntValue(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.parse(value);
      throw FormatException('Cannot parse $value to int');
    }

    return Quiz(
      questionId: parseIntValue(json['question_id']),
      questionNumber: parseIntValue(json['question_number']),
      questionText: json['question_text'] as String,
      choice1: json['choice_1'] as String,
      choice2: json['choice_2'] as String,
      choice3: json['choice_3'] as String,
      choice4: json['choice_4'] as String,
      correctChoiceNumber: parseIntValue(json['correct_choice_number']),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

@freezed
class QuizResponse with _$QuizResponse {
  const factory QuizResponse({
    required Book book,
    required List<Quiz> quizzes,
  }) = _QuizResponse;
}
