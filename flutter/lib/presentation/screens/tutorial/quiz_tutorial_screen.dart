import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/tutorial_highlight_box.dart';
import 'tutorial_dummy_data.dart';

class QuizTutorialScreen extends StatefulWidget {
  const QuizTutorialScreen({super.key});

  @override
  State<QuizTutorialScreen> createState() => _QuizTutorialScreenState();
}

class _QuizTutorialScreenState extends State<QuizTutorialScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  int? _selectedAnswer;

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      context.go('/tutorial/words');
    }
  }

  void _skipTutorial() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final book = TutorialDummyData.tutorialBook;
    final questions = TutorialDummyData.sampleQuizQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _skipTutorial,
        ),
      ),
      body: Column(
        children: [
          TutorialBanner(
            title: '📝 퀴즈 풀기',
            description: _getStepDescription(),
            onNext: _nextStep,
            onSkip: _skipTutorial,
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book info
                  _currentStep == 1
                      ? TutorialHighlightBox(
                          instructionText: '책 정보를 확인하세요',
                          child: _buildBookInfo(book),
                        )
                      : _buildBookInfo(book),
                  const SizedBox(height: 24),

                  // Quiz question
                  _currentStep == 2
                      ? TutorialHighlightBox(
                          instructionText: '문제를 읽고 정답을 선택하세요',
                          child: _buildQuizCard(questions[0]),
                        )
                      : _buildQuizCard(questions[0]),

                  if (_currentStep == 3 && _selectedAnswer != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '정답을 선택하면 즉시 결과를 확인할 수 있습니다!',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 1:
        return '책의 제목, 저자, 총 퀴즈 개수를 확인할 수 있습니다';
      case 2:
        return '퀴즈 문제를 읽고 4개의 보기 중 정답을 선택하세요';
      case 3:
        return '정답을 선택하면 바로 피드백을 받을 수 있습니다';
      default:
        return '';
    }
  }

  Widget _buildBookInfo(book) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              book.author,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total ${TutorialDummyData.sampleQuizQuestions.length} quizzes',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quizData) {
    final hasAnswered = _selectedAnswer != null;
    final isCorrect = _selectedAnswer == quizData['correctAnswer'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Question 1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quizData['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Choices
            ...List.generate(4, (index) {
              return _buildChoice(
                index,
                quizData['choices'][index],
                hasAnswered,
                quizData['correctAnswer'],
              );
            }),

            // Result
            if (hasAnswered) ...[
              const SizedBox(height: 16),
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
                        isCorrect ? 'Correct! 정답입니다!' : 'Incorrect. 오답입니다. 정답을 확인하세요.',
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoice(int index, String text, bool hasAnswered, int correctAnswer) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == correctAnswer;

    Color? backgroundColor;
    Color borderColor;

    if (hasAnswered) {
      if (isSelected && isCorrect) {
        backgroundColor = Colors.green[50];
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[50];
        borderColor = Colors.red;
      } else if (!isSelected && isCorrect) {
        backgroundColor = Colors.green[50];
        borderColor = Colors.green;
      } else {
        backgroundColor = Colors.grey[50];
        borderColor = Colors.grey.shade300;
      }
    } else {
      backgroundColor = isSelected ? Colors.blue[50] : null;
      borderColor = isSelected ? Colors.blue : Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: hasAnswered ? null : () {
        setState(() => _selectedAnswer = index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (hasAnswered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (hasAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
