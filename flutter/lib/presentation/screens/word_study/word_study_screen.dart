import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/word_provider.dart';
import '../../providers/user_word_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/word_card_widget.dart';
import 'package:reading_turtle/domain/entities/word.dart';

class WordStudyScreen extends ConsumerStatefulWidget {
  final String isbn;

  const WordStudyScreen({
    super.key,
    required this.isbn,
  });

  @override
  ConsumerState<WordStudyScreen> createState() => _WordStudyScreenState();
}

class _WordStudyScreenState extends ConsumerState<WordStudyScreen> {
  String _filter = 'all'; // all, known, unknown, bookmarked

  @override
  void initState() {
    super.initState();
    // Load words when screen initializes
    Future.microtask(() {
      ref.read(wordProvider.notifier).loadWords(widget.isbn);

      // Load user word progress if authenticated
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        ref.read(userWordProvider.notifier).loadWordProgress(widget.isbn);
      }
    });
  }

  List<Word> _getFilteredWords(List<Word> words) {
    switch (_filter) {
      case 'known':
        return words.where((w) => w.isKnown).toList();
      case 'unknown':
        return words.where((w) => !w.isKnown).toList();
      case 'bookmarked':
        return words.where((w) => w.isBookmarked).toList();
      default:
        return words;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordState = ref.watch(wordProvider);
    final userWordState = ref.watch(userWordProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    // Merge word data with user progress using word string as key
    final List<Word> wordsWithProgress = isLoggedIn
        ? userWordState.maybeWhen(
            loaded: (wordProgress, stats) {
              return wordState.words.map((word) {
                final progress = wordProgress[word.word];
                if (progress != null) {
                  return word.copyWith(
                    isKnown: progress.isKnown,
                    isBookmarked: progress.isBookmarked,
                    studyCount: progress.studyCount,
                  );
                }
                return word;
              }).toList();
            },
            orElse: () => wordState.words,
          )
        : wordState.words;

    final filteredWords = _getFilteredWords(wordsWithProgress);
    final knownCount = wordsWithProgress.where((w) => w.isKnown).length;
    final totalCount = wordsWithProgress.length;
    final progressPercent = totalCount > 0 ? (knownCount / totalCount * 100).toStringAsFixed(0) : '0';

    return wordState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wordState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading words',
                        style: TextStyle(color: Colors.red[700], fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(wordState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(wordProvider.notifier).loadWords(widget.isbn),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : wordState.words.isEmpty
                  ? const Center(
                      child: Text(
                        'No words available for this book',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Column(
                      children: [
                        // Header with word count and progress
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.green[50],
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Words: $totalCount',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isLoggedIn) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '알고있음: $knownCount ($progressPercent%)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              if (isLoggedIn) ...[
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: totalCount > 0 ? knownCount / totalCount : 0,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                                  minHeight: 8,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Filter buttons
                        if (isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('전체', 'all', totalCount),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                    '알고있음',
                                    'known',
                                    wordsWithProgress.where((w) => w.isKnown).length,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                    '모름',
                                    'unknown',
                                    wordsWithProgress.where((w) => !w.isKnown).length,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                    '북마크',
                                    'bookmarked',
                                    wordsWithProgress.where((w) => w.isBookmarked).length,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Word list
                        Expanded(
                          child: filteredWords.isEmpty
                              ? Center(
                                  child: Text(
                                    _filter == 'all'
                                        ? 'No words available'
                                        : 'No words in this category',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredWords.length,
                                  itemBuilder: (context, index) {
                                    final word = filteredWords[index];
                                    return WordCardWidget(word: word);
                                  },
                                ),
                        ),
                      ],
                    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
    );
  }
}
