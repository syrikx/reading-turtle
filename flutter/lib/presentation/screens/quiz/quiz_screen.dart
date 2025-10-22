import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/quiz_item_widget.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String isbn;

  const QuizScreen({super.key, required this.isbn});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Load quizzes when screen is initialized
    Future.microtask(() {
      ref.read(quizProvider.notifier).loadQuizzes(widget.isbn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    return _buildBody(quizState);
  }

  Widget _buildBody(quizState) {
    if (quizState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (quizState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${quizState.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(quizProvider.notifier).loadQuizzes(widget.isbn);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (quizState.quizzes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No quizzes available for this book',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Info Header
          if (quizState.book != null) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quizState.book!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quizState.book!.author,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total ${quizState.quizzes.length} quizzes',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Quizzes List
          ...quizState.quizzes.map((quiz) {
            final userAnswer = quizState.userAnswers[quiz.questionId];
            return QuizItemWidget(
              quiz: quiz,
              userAnswer: userAnswer,
              onAnswerSelected: (selectedChoice) {
                ref
                    .read(quizProvider.notifier)
                    .answerQuestion(quiz.questionId, selectedChoice);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
