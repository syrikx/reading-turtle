import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/tutorial_highlight_box.dart';
import '../../widgets/book_card.dart';
import 'tutorial_dummy_data.dart';

class SearchTutorialScreen extends StatefulWidget {
  const SearchTutorialScreen({super.key});

  @override
  State<SearchTutorialScreen> createState() => _SearchTutorialScreenState();
}

class _SearchTutorialScreenState extends State<SearchTutorialScreen> {
  final _searchController = TextEditingController(text: 'Harry Potter');
  String? _selectedGenre;
  bool _hasQuiz = false;
  bool _hasWords = false;
  RangeValues _btLevelRange = const RangeValues(0, 10);
  int _currentStep = 1;
  final int _totalSteps = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      // Go to next tutorial screen
      context.go('/tutorial/quiz');
    }
  }

  void _skipTutorial() {
    context.go('/');
  }

  bool get _isAllFiltersOff {
    return _selectedGenre == null && !_hasQuiz && !_hasWords;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGenre = null;
      _hasQuiz = false;
      _hasWords = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _skipTutorial,
        ),
      ),
      body: Column(
        children: [
          // Tutorial banner
          TutorialBanner(
            title: '📚 도서 검색하기',
            description: _getStepDescription(),
            onNext: _nextStep,
            onSkip: _skipTutorial,
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),

          // Search interface
          Expanded(
            child: Column(
              children: [
                // Filter section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      // Row 1: Search input + Search button
                      _currentStep == 1
                          ? TutorialHighlightBox(
                              instructionText: '책 제목, 저자, ISBN을 입력하세요',
                              child: _buildSearchRow(),
                            )
                          : _buildSearchRow(),
                      const SizedBox(height: 8),

                      // Row 2: Filter buttons
                      _currentStep == 2
                          ? TutorialHighlightBox(
                              instructionText: '장르나 퀴즈/단어 여부로 필터링하세요',
                              child: _buildFilterButtons(),
                            )
                          : _buildFilterButtons(),
                      const SizedBox(height: 8),

                      // Row 3: Level slider
                      _currentStep == 3
                          ? TutorialHighlightBox(
                              instructionText: 'BT 레벨을 조절하여 난이도를 선택하세요',
                              child: _buildLevelSlider(),
                            )
                          : _buildLevelSlider(),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: _currentStep == 4
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.red.shade50,
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '검색 결과입니다. 책을 클릭하면 퀴즈나 단어를 학습할 수 있어요!',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: _buildResults()),
                          ],
                        )
                      : _currentStep == 5
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.orange.shade50,
                                  child: Row(
                                    children: [
                                      Icon(Icons.touch_app, color: Colors.orange.shade700),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '책 읽기 전에 Words 버튼을 눌러서 단어를 공부하고, 책 읽고 나서 Quiz 버튼을 눌러서 내용 파악을 확인하세요!',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: _buildResults(highlightFirst: true)),
                              ],
                            )
                          : _buildResults(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 1:
        return '검색창에 책 제목이나 저자를 입력해보세요';
      case 2:
        return '장르, 퀴즈 유무, 단어 유무로 책을 필터링할 수 있습니다';
      case 3:
        return 'BT 레벨(0~10)을 조절하여 적절한 난이도의 책을 찾으세요';
      case 4:
        return '검색 결과가 표시됩니다. 책을 클릭하면 자세한 정보를 볼 수 있어요';
      case 5:
        return '책 카드의 Quiz/Words 버튼을 클릭하여 학습을 시작하세요!';
      default:
        return '';
    }
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(child: _buildAllButton()),
        const SizedBox(width: 4),
        Expanded(child: _buildGenreButton('Fiction', 'fiction')),
        const SizedBox(width: 4),
        Expanded(child: _buildGenreButton('Nonfiction', 'nonfiction')),
        const SizedBox(width: 4),
        Expanded(
          child: _buildToggleButton('Quiz', _hasQuiz, (val) {
            setState(() => _hasQuiz = val);
          }),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildToggleButton('Words', _hasWords, (val) {
            setState(() => _hasWords = val);
          }),
        ),
      ],
    );
  }

  Widget _buildLevelSlider() {
    return Row(
      children: [
        const Text('Level:', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: RangeSlider(
            values: _btLevelRange,
            min: 0,
            max: 10,
            divisions: 20,
            activeColor: Colors.green,
            labels: RangeLabels(
              _btLevelRange.start.toStringAsFixed(1),
              _btLevelRange.end.toStringAsFixed(1),
            ),
            onChanged: (values) {
              setState(() => _btLevelRange = values);
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${TutorialDummyData.sampleBooks.length} books',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAllButton() {
    final isSelected = _isAllFiltersOff;
    return GestureDetector(
      onTap: () {
        if (!isSelected) _clearAllFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'All',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGenreButton(String label, String genre) {
    final isSelected = _selectedGenre == genre;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGenre = isSelected ? null : genre;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, Function(bool) onToggle) {
    return GestureDetector(
      onTap: () => onToggle(!isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange : Colors.white,
          border: Border.all(
            color: isActive ? Colors.orange : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildResults({bool highlightFirst = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 6;
          childAspectRatio = 0.7;
        } else if (constraints.maxWidth >= 1200) {
          crossAxisCount = 5;
          childAspectRatio = 0.7;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
          childAspectRatio = 0.68;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.65;
        } else if (constraints.maxWidth >= 400) {
          crossAxisCount = 2;
          childAspectRatio = 0.65;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 0.7;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: TutorialDummyData.sampleBooks.length,
          itemBuilder: (context, index) {
            final book = TutorialDummyData.sampleBooks[index];
            Widget card = BookCard(
              book: book,
              animateButtons: highlightFirst && index == 0,
            );

            // Highlight first card on step 5
            if (highlightFirst && index == 0) {
              return TutorialHighlightBox(
                instructionText: '📝 Quiz 버튼: 퀴즈 시작 | 📖 Words 버튼: 단어 학습',
                child: card,
                highlightColor: Colors.orange,
              );
            }

            return card;
          },
        );
      },
    );
  }
}
