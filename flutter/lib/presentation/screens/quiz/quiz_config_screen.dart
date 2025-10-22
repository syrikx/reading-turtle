import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizConfigScreen extends ConsumerStatefulWidget {
  const QuizConfigScreen({super.key});

  @override
  ConsumerState<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends ConsumerState<QuizConfigScreen> {
  String _quizType = 'level'; // 'level', 'known', 'bookmarked', 'studied', 'wrong_answers'
  double _minLevel = 1.0;
  double _maxLevel = 3.0;
  int _questionCount = 10;

  void _startQuiz() {
    if (_quizType == 'level') {
      // Navigate to quiz with level filter
      context.go('/quiz-level?minLevel=$_minLevel&maxLevel=$_maxLevel&count=$_questionCount');
    } else if (_quizType == 'wrong_answers') {
      // Navigate to wrong answers quiz
      context.go('/quiz-wrong-answers?count=$_questionCount');
    } else {
      // Navigate to user words quiz (known/bookmarked/studied)
      context.go('/quiz-user-words?filter=$_quizType&count=$_questionCount');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 단어 시험 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Type Selection
            Text(
              '시험 유형 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildQuizTypeCard(
              type: 'level',
              title: '레벨별 시험',
              subtitle: '단어 레벨을 선택하여 시험',
              icon: Icons.layers,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildQuizTypeCard(
              type: 'known',
              title: '알고있는 단어',
              subtitle: '내가 표시한 아는 단어로 시험',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildQuizTypeCard(
              type: 'bookmarked',
              title: '북마크 단어',
              subtitle: '북마크한 단어로 시험',
              icon: Icons.bookmark,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildQuizTypeCard(
              type: 'studied',
              title: '학습한 단어',
              subtitle: '학습 기록이 있는 단어로 시험',
              icon: Icons.school,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildQuizTypeCard(
              type: 'wrong_answers',
              title: '오답 노트',
              subtitle: '틀렸던 단어만 다시 시험',
              icon: Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(height: 32),

            // Level Range (only for level quiz)
            if (_quizType == 'level') ...[
              Text(
                '단어 레벨 범위',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('최소 레벨: ${_minLevel.toStringAsFixed(1)}'),
                        Slider(
                          value: _minLevel,
                          min: 0.5,
                          max: 9.5,
                          divisions: 18,
                          label: _minLevel.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _minLevel = value;
                              if (_minLevel >= _maxLevel) {
                                _maxLevel = _minLevel + 0.5;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('최대 레벨: ${_maxLevel.toStringAsFixed(1)}'),
                        Slider(
                          value: _maxLevel,
                          min: 1.0,
                          max: 10.0,
                          divisions: 18,
                          label: _maxLevel.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _maxLevel = value;
                              if (_maxLevel <= _minLevel) {
                                _minLevel = _maxLevel - 0.5;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Question Count
            Text(
              '문제 개수',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('문제 수: $_questionCount개'),
                ),
                Expanded(
                  child: Slider(
                    value: _questionCount.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: _questionCount.toString(),
                    onChanged: (value) {
                      setState(() {
                        _questionCount = value.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  '시험 시작',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _quizType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _quizType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
