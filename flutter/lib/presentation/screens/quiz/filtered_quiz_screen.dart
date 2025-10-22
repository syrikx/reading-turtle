import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/api/quiz_api_service.dart';
import '../../../domain/entities/quiz.dart';
import '../../providers/auth_provider.dart';

class FilteredQuizScreen extends ConsumerStatefulWidget {
  final String quizType; // 'level', 'user_words', 'wrong_answers'
  final Map<String, String> queryParams;

  const FilteredQuizScreen({
    super.key,
    required this.quizType,
    required this.queryParams,
  });

  @override
  ConsumerState<FilteredQuizScreen> createState() => _FilteredQuizScreenState();
}

class _FilteredQuizScreenState extends ConsumerState<FilteredQuizScreen> {
  List<Map<String, dynamic>> _quizzes = [];
  int _currentIndex = 0;
  int _score = 0;
  List<Map<String, dynamic>> _wrongAnswers = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedAnswer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final quizService = QuizApiService(apiClient);

      Map<String, dynamic> response;

      if (widget.quizType == 'level') {
        final minLevel = double.parse(widget.queryParams['minLevel'] ?? '1.0');
        final maxLevel = double.parse(widget.queryParams['maxLevel'] ?? '3.0');
        final count = int.parse(widget.queryParams['count'] ?? '10');

        response = await quizService.getQuizByLevel(
          minLevel: minLevel,
          maxLevel: maxLevel,
          count: count,
        );
      } else if (widget.quizType == 'user_words') {
        final filter = widget.queryParams['filter'] ?? 'known';
        final count = int.parse(widget.queryParams['count'] ?? '10');

        response = await quizService.getQuizByUserWords(
          filter: filter,
          count: count,
        );
      } else if (widget.quizType == 'wrong_answers') {
        final count = int.parse(widget.queryParams['count'] ?? '10');

        response = await quizService.getQuizByWrongAnswers(count: count);
      } else {
        throw Exception('Unknown quiz type: ${widget.quizType}');
      }

      final data = response['data'] as Map<String, dynamic>;
      final quizzes = data['quizzes'] as List;

      setState(() {
        _quizzes = quizzes.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_showResult) return;

    setState(() {
      _selectedAnswer = answer;
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null || _showResult) return;

    final currentQuiz = _quizzes[_currentIndex];
    final correctAnswer = currentQuiz['correctAnswer'] as String;
    final isCorrect = _selectedAnswer == correctAnswer;

    if (isCorrect) {
      _score++;
    } else {
      // Record wrong answer
      _wrongAnswers.add({
        'word_id': currentQuiz['correctWordId'],
        'word': correctAnswer,
        'selected': _selectedAnswer,
        'definition': currentQuiz['definition'],
      });

      // Save to backend
      try {
        final apiClient = ref.read(apiClientProvider);
        final quizService = QuizApiService(apiClient);

        String? quizType;
        String? filterValue;

        if (widget.quizType == 'level') {
          quizType = 'level';
          filterValue = '${widget.queryParams['minLevel']}-${widget.queryParams['maxLevel']}';
        } else if (widget.quizType == 'user_words') {
          quizType = widget.queryParams['filter'];
          filterValue = widget.queryParams['filter'];
        } else if (widget.quizType == 'wrong_answers') {
          quizType = 'wrong_answers';
          filterValue = 'retry';
        }

        await quizService.recordWrongAnswer(
          wordId: currentQuiz['correctWordId'] as int,
          word: correctAnswer,
          quizType: quizType,
          quizFilterValue: filterValue,
        );
      } catch (e) {
        print('Failed to record wrong answer: $e');
      }
    }

    setState(() {
      _showResult = true;
    });

    // Auto advance after 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentIndex < _quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      _showFinalResults();
    }
  }

  String _hideAnswerInSentence(String sentence, String answer) {
    // Hide the answer word in the sentence with blanks
    // Case-insensitive replacement
    final pattern = RegExp(answer, caseSensitive: false);
    return sentence.replaceAll(pattern, '____');
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('시험 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '점수: $_score / ${_quizzes.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '정답률: ${((_score / _quizzes.length) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
            if (_wrongAnswers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '틀린 문제: ${_wrongAnswers.length}개',
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                '오답 노트에 저장되었습니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          if (_wrongAnswers.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/wrong-answers-list');
              },
              child: const Text('오답 노트 보기'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/mypage');
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_quizzes.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getTitle() {
    if (widget.quizType == 'level') {
      return '레벨 ${widget.queryParams['minLevel']}~${widget.queryParams['maxLevel']} 시험';
    } else if (widget.quizType == 'user_words') {
      final filter = widget.queryParams['filter'];
      if (filter == 'known') return '알고있는 단어 시험';
      if (filter == 'bookmarked') return '북마크 단어 시험';
      if (filter == 'studied') return '학습한 단어 시험';
    } else if (widget.quizType == 'wrong_answers') {
      return '오답 노트 시험';
    }
    return '단어 시험';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/quiz-config'),
              child: const Text('다시 설정하기'),
            ),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('문제가 없습니다'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/quiz-config'),
              child: const Text('다시 설정하기'),
            ),
          ],
        ),
      );
    }

    final quiz = _quizzes[_currentIndex];
    final choices = quiz['choices'] as List;
    final correctAnswer = quiz['correctAnswer'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _quizzes.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 24),

          // Score
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '현재 점수: $_score / ${_currentIndex + (_showResult ? 1 : 0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (quiz['btLevel'] != null)
                  Text(
                    'Level: ${quiz['btLevel']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Question
          Text(
            '다음 뜻에 맞는 단어를 고르세요:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz['definition'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                if (quiz['exampleSentence'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '예문:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hideAnswerInSentence(
                      quiz['exampleSentence'] as String,
                      correctAnswer,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Choices
          ...choices.asMap().entries.map((entry) {
            final choice = entry.value as Map<String, dynamic>;
            final word = choice['word'] as String;
            final isSelected = _selectedAnswer == word;
            final isCorrect = word == correctAnswer;

            Color? backgroundColor;
            Color? borderColor;

            if (_showResult) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.2);
                borderColor = Colors.green;
              } else if (isSelected) {
                backgroundColor = Colors.red.withOpacity(0.2);
                borderColor = Colors.red;
              }
            } else if (isSelected) {
              backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
              borderColor = Theme.of(context).primaryColor;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _selectAnswer(word),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor ?? Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        String.fromCharCode(65 + entry.key), // A, B, C, D, E
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: borderColor ?? Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_showResult && isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      if (_showResult && isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: Colors.red, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Submit button
          if (!_showResult)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer != null ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  '정답 확인',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
