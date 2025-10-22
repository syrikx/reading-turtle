import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_turtle/domain/entities/book.dart';
import '../../providers/reading_status_provider.dart';
import '../../providers/reading_status_state.dart';
import '../../providers/user_word_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../widgets/book_card.dart';
import '../../widgets/stat_card.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Load reading history and stats on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(readingStatusProvider.notifier).loadHistory();
      ref.read(readingStatusProvider.notifier).loadStats();
      // Load user word statistics only (not specific to any book)
      await ref.read(userWordProvider.notifier).loadStats();

      // Try to load word progress from the first book in reading history
      // This populates the word progress data for My Words screen
      final readingState = ref.read(readingStatusProvider);
      readingState.maybeWhen(
        loaded: (readingBooks, allBooks, stats, isUpdating, currentFilter) {
          if (allBooks.isNotEmpty) {
            // Load words from the first book to populate word progress
            ref.read(userWordProvider.notifier).loadWordProgress(allBooks.first.isbn);
          }
        },
        orElse: () {},
      );
    });
  }

  void _onFilterChanged(String? filter) {
    setState(() {
      _selectedFilter = filter;
    });
    ref.read(readingStatusProvider.notifier).filterByStatus(filter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 내 독서 기록'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('홈으로'),
          ),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (readingBooks, allBooks, stats, isUpdating, currentFilter) {
          return _buildContent(
            context,
            readingBooks: readingBooks,
            allBooks: allBooks,
            stats: stats,
            isUpdating: isUpdating,
          );
        },
        error: (message) => Center(
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
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(readingStatusProvider.notifier).loadHistory();
                  ref.read(readingStatusProvider.notifier).loadStats();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<Book> readingBooks,
    required List<Book> allBooks,
    required ReadingStats? stats,
    required bool isUpdating,
  }) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          if (stats != null) ...[
            _buildStatsGrid(stats),
            const SizedBox(height: 32),
          ],

          // Word Study Stats
          _buildWordStudySection(context),
          const SizedBox(height: 24),

          // Settings Section
          _buildSettingsSection(context),
          const SizedBox(height: 24),

          // Quiz Buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/quiz-config'),
                  icon: const Icon(Icons.quiz, size: 24),
                  label: const Text(
                    '📝 단어 시험',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/wrong-answers-list'),
                  icon: const Icon(Icons.error_outline, size: 20),
                  label: const Text(
                    '오답',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Filter Buttons
          Text(
            '독서 기록',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildFilterButtons(),
          const SizedBox(height: 16),

          // Empty or Books Grid
          if (allBooks.isEmpty)
            // Empty State
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '아직 독서 기록이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '책을 검색하고 읽기 시작해보세요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/search'),
                      icon: const Icon(Icons.search),
                      label: const Text('책 검색하기'),
                    ),
                  ],
                ),
              ),
            )
          else
            // Books Grid
            _buildBooksGrid(context, allBooks),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ReadingStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: 1 column on mobile, 2 on tablet, 4 on desktop
        int crossAxisCount;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            StatCard(
              title: '읽는 중',
              count: stats.readingCount,
              icon: Icons.book_outlined,
              color: Colors.teal,
            ),
            StatCard(
              title: '읽음',
              count: stats.completedCount,
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            StatCard(
              title: '전체',
              count: stats.totalCount,
              icon: Icons.library_books_outlined,
              color: Colors.blue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip('전체', null),
        _buildFilterChip('읽는 중', 'reading'),
        _buildFilterChip('읽음', 'completed'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _selectedFilter == filterValue;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _onFilterChanged(filterValue),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
    );
  }

  Widget _buildBooksGrid(BuildContext context, List<Book> books) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 400) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookCard(
              book: books[index],
              showStatusButtons: true,
              showDates: true,
            );
          },
        );
      },
    );
  }

  Widget _buildWordStudySection(BuildContext context) {
    final userWordState = ref.watch(userWordProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📖 단어 학습 현황',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to all known words page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('아는 단어 전체 보기 기능 준비 중')),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        userWordState.maybeWhen(
          loaded: (wordProgress, stats) {
            return Column(
              children: [
                // Stats Grid - Compact cards
                Row(
                  children: [
                    Expanded(
                      child: _buildWordStatCard(
                        context,
                        title: '알고있음',
                        count: stats.knownWords,
                        icon: Icons.check_circle,
                        color: Colors.green,
                        filterType: 'known',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWordStatCard(
                        context,
                        title: '북마크',
                        count: stats.bookmarkedWords,
                        icon: Icons.bookmark,
                        color: Colors.orange,
                        filterType: 'bookmarked',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWordStatCard(
                        context,
                        title: '학습한 단어',
                        count: stats.studiedWords,
                        icon: Icons.school,
                        color: Colors.purple,
                        filterType: 'studied',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Known Words Sample List
                if (wordProgress.isNotEmpty) ...[
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '최근 학습한 단어',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...wordProgress.values
                              .where((w) => w.isKnown || w.isBookmarked)
                              .take(5)
                              .map((word) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        if (word.isKnown)
                                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                        if (word.isBookmarked)
                                          const Icon(Icons.bookmark, color: Colors.orange, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            word.word,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        if (word.studyCount != null && word.studyCount! > 0)
                                          Text(
                                            '${word.studyCount}회',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          if (wordProgress.values.where((w) => w.isKnown || w.isBookmarked).length > 5)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '+ ${wordProgress.values.where((w) => w.isKnown || w.isBookmarked).length - 5}개 더',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (message) => Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '단어 학습 데이터를 불러올 수 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          orElse: () => Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.book_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    '아직 학습한 단어가 없습니다',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '책을 읽고 단어를 학습해보세요!',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String filterType,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to word list screen with filter
        context.go('/my-words/$filterType');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count개',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final preferences = ref.watch(userPreferencesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  '환경 설정',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '책 레벨 표시 방식',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SegmentedButton<LevelDisplayType>(
                  segments: const [
                    ButtonSegment<LevelDisplayType>(
                      value: LevelDisplayType.btLevel,
                      label: Text('Lv.'),
                      icon: Icon(Icons.star, size: 16),
                    ),
                    ButtonSegment<LevelDisplayType>(
                      value: LevelDisplayType.lexile,
                      label: Text('Lexile'),
                      icon: Icon(Icons.text_fields, size: 16),
                    ),
                  ],
                  selected: {preferences.levelDisplayType},
                  onSelectionChanged: (Set<LevelDisplayType> newSelection) {
                    ref.read(userPreferencesProvider.notifier)
                        .setLevelDisplayType(newSelection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preferences.levelDisplayType == LevelDisplayType.btLevel
                  ? 'BT 레벨을 "Lv."로 표시합니다'
                  : 'Lexile 레벨을 표시합니다',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
