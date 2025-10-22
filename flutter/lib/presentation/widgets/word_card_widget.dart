import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/word.dart';
import '../providers/user_word_provider.dart';
import '../providers/auth_provider.dart';

class WordCardWidget extends ConsumerStatefulWidget {
  final Word word;

  const WordCardWidget({
    super.key,
    required this.word,
  });

  @override
  ConsumerState<WordCardWidget> createState() => _WordCardWidgetState();
}

class _WordCardWidgetState extends ConsumerState<WordCardWidget> {
  bool _isUpdating = false;

  Future<void> _toggleKnown() async {
    if (widget.word.wordId == null) return;

    setState(() => _isUpdating = true);

    try {
      await ref.read(userWordProvider.notifier).toggleKnown(
            widget.word.wordId!,
            widget.word.word,
            !widget.word.isKnown,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.word.isKnown
                  ? '단어를 "모름"으로 표시했습니다'
                  : '단어를 "알고있음"으로 표시했습니다',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (widget.word.wordId == null) return;

    setState(() => _isUpdating = true);

    try {
      await ref.read(userWordProvider.notifier).toggleBookmark(
            widget.word.wordId!,
            widget.word.word,
            !widget.word.isBookmarked,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.word.isBookmarked
                  ? '북마크를 해제했습니다'
                  : '북마크에 추가했습니다',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    // Watch user word state to get real-time updates
    final userWordState = ref.watch(userWordProvider);

    // Merge word data with user progress using word string as key
    final Word displayWord = userWordState.maybeWhen(
      loaded: (wordProgress, stats) {
        final progress = wordProgress[widget.word.word];
        if (progress != null) {
          return widget.word.copyWith(
            isKnown: progress.isKnown,
            isBookmarked: progress.isBookmarked,
            studyCount: progress.studyCount,
          );
        }
        return widget.word;
      },
      orElse: () => widget.word,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word and Level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayWord.word,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: displayWord.isKnown ? Colors.grey : Colors.green,
                      decoration: displayWord.isKnown
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (displayWord.minBtLevel != null || displayWord.minLexile != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          displayWord.minBtLevel != null
                              ? 'BT ${displayWord.minBtLevel}'
                              : 'L ${displayWord.minLexile}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isLoggedIn && displayWord.wordId != null) ...[
                      const SizedBox(width: 8),
                      // Bookmark button
                      IconButton(
                        icon: Icon(
                          displayWord.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: displayWord.isBookmarked
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        onPressed: _isUpdating ? null : _toggleBookmark,
                        tooltip: displayWord.isBookmarked ? '북마크 해제' : '북마크',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (displayWord.definition != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Definition:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayWord.definition!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            if (displayWord.exampleSentence != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Example:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayWord.exampleSentence!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            // Action buttons (if logged in)
            if (isLoggedIn && displayWord.wordId != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (displayWord.studyCount != null && displayWord.studyCount! > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '학습 ${displayWord.studyCount}회',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _toggleKnown,
                    icon: Icon(
                      displayWord.isKnown ? Icons.check_circle : Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: Text(displayWord.isKnown ? '알고있음' : '알고있음으로 표시'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: displayWord.isKnown ? Colors.green : Colors.white,
                      foregroundColor: displayWord.isKnown ? Colors.white : Colors.green,
                      side: BorderSide(
                        color: Colors.green,
                        width: displayWord.isKnown ? 0 : 1,
                      ),
                      elevation: displayWord.isKnown ? 2 : 0,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
