import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/tutorial_highlight_box.dart';
import 'tutorial_dummy_data.dart';

class WordsTutorialScreen extends StatefulWidget {
  const WordsTutorialScreen({super.key});

  @override
  State<WordsTutorialScreen> createState() => _WordsTutorialScreenState();
}

class _WordsTutorialScreenState extends State<WordsTutorialScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  final Map<int, bool> _knownWords = {};
  final Map<int, bool> _bookmarkedWords = {};

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      context.go('/tutorial/calendar');
    }
  }

  void _skipTutorial() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final book = TutorialDummyData.tutorialBook;
    final words = TutorialDummyData.sampleWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Study'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _skipTutorial,
        ),
      ),
      body: Column(
        children: [
          TutorialBanner(
            title: '📖 단어 학습하기',
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
                  _buildBookInfo(book),
                  const SizedBox(height: 16),

                  // Stats
                  _buildStats(words),
                  const SizedBox(height: 24),

                  // Word list
                  ...words.asMap().entries.map((entry) {
                    final index = entry.key;
                    final word = entry.value;

                    Widget wordCard = _buildWordCard(index, word);

                    if (_currentStep == 1 && index == 0) {
                      return TutorialHighlightBox(
                        instructionText: '단어의 뜻과 예문을 확인하세요',
                        child: wordCard,
                      );
                    } else if (_currentStep == 2 && index == 1) {
                      return TutorialHighlightBox(
                        instructionText: '"아는 단어" 버튼을 클릭하여 학습 진행도를 체크하세요',
                        child: wordCard,
                      );
                    } else if (_currentStep == 3 && index == 2) {
                      return TutorialHighlightBox(
                        instructionText: '중요한 단어는 북마크하여 나중에 다시 학습할 수 있어요',
                        child: wordCard,
                      );
                    }

                    return wordCard;
                  }).toList(),
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
        return '책에 나오는 중요 단어의 뜻과 예문을 학습하세요';
      case 2:
        return '아는 단어는 "아는 단어"로 표시하여 진도를 관리하세요';
      case 3:
        return '중요한 단어는 북마크하여 나중에 복습할 수 있습니다';
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
          ],
        ),
      ),
    );
  }

  Widget _buildStats(List<Map<String, dynamic>> words) {
    final knownCount = _knownWords.values.where((v) => v).length;
    final bookmarkedCount = _bookmarkedWords.values.where((v) => v).length;

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    '$knownCount / ${words.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Known Words',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    '$bookmarkedCount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bookmarked',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(int index, Map<String, dynamic> wordData) {
    final isKnown = _knownWords[index] ?? wordData['known'];
    final isBookmarked = _bookmarkedWords[index] ?? wordData['bookmarked'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  wordData['word'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _bookmarkedWords[index] = !isBookmarked;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Definition',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wordData['definition'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wordData['example'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _knownWords[index] = !isKnown;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isKnown ? Colors.green : Colors.grey[300],
                  foregroundColor: isKnown ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(isKnown ? Icons.check_circle : Icons.circle_outlined),
                label: Text(isKnown ? '아는 단어' : '모르는 단어'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
