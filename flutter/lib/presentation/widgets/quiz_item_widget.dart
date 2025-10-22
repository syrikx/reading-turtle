import 'package:flutter/material.dart';
import '../../domain/entities/quiz.dart';

class QuizItemWidget extends StatelessWidget {
  final Quiz quiz;
  final int? userAnswer;
  final Function(int) onAnswerSelected;

  const QuizItemWidget({
    super.key,
    required this.quiz,
    required this.userAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswered = userAnswer != null;
    final isCorrect = userAnswer == quiz.correctChoiceNumber;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Question ${quiz.questionNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Question Text
            Text(
              quiz.questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Choices
            _buildChoice(1, quiz.choice1, hasAnswered),
            _buildChoice(2, quiz.choice2, hasAnswered),
            _buildChoice(3, quiz.choice3, hasAnswered),
            _buildChoice(4, quiz.choice4, hasAnswered),

            // Result and Answer
            if (hasAnswered) ...[
              const SizedBox(height: 16),
              // Result Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isCorrect ? 'Correct!' : 'Incorrect. Check the answer below.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCorrect ? Colors.green[900] : Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Correct Answer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        'Correct Answer: ${quiz.correctChoiceNumber}. ${quiz.correctAnswer}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoice(int choiceNumber, String choiceText, bool hasAnswered) {
    final isSelected = userAnswer == choiceNumber;
    final isSelectedCorrect = hasAnswered && isSelected && (userAnswer == quiz.correctChoiceNumber);
    final isSelectedIncorrect = hasAnswered && isSelected && (userAnswer != quiz.correctChoiceNumber);

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (hasAnswered) {
      if (isSelectedCorrect) {
        // User selected this choice and it's correct
        backgroundColor = Colors.green[50];
        borderColor = Colors.green;
        textColor = Colors.green[900];
      } else if (isSelectedIncorrect) {
        // User selected this choice and it's incorrect
        backgroundColor = Colors.red[50];
        borderColor = Colors.red;
        textColor = Colors.red[900];
      } else {
        // User didn't select this choice
        backgroundColor = Colors.grey[100];
        borderColor = Colors.grey[400];
        textColor = Colors.grey[700];
      }
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey[300];
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: hasAnswered ? null : () => onAnswerSelected(choiceNumber),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelectedCorrect
                    ? Colors.green
                    : isSelectedIncorrect
                        ? Colors.red
                        : Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  '$choiceNumber',
                  style: TextStyle(
                    color: isSelectedCorrect || isSelectedIncorrect ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                choiceText,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
