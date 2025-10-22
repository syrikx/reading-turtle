import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/api/user_word_api_service.dart';
import '../../providers/user_word_provider.dart';
import '../../providers/user_word_state.dart';

class MyWordsScreen extends ConsumerStatefulWidget {
  final String filterType; // 'known', 'bookmarked', 'studied'

  const MyWordsScreen({
    super.key,
    required this.filterType,
  });

  @override
  ConsumerState<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends ConsumerState<MyWordsScreen> {
  List<UserWordProgress> _words = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(userWordApiServiceProvider);
      final response = await apiService.getAllUserWords(filter: widget.filterType);

      final data = response['data'] as List;
      final words = data.map((item) => UserWordProgress.fromJson(item as Map<String, dynamic>)).toList();

      setState(() {
        _words = words;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String get _title {
    switch (widget.filterType) {
      case 'known':
        return '알고있는 단어';
      case 'bookmarked':
        return '북마크한 단어';
      case 'studied':
        return '학습한 단어';
      default:
        return '내 단어';
    }
  }

  IconData get _icon {
    switch (widget.filterType) {
      case 'known':
        return Icons.check_circle;
      case 'bookmarked':
        return Icons.bookmark;
      case 'studied':
        return Icons.school;
      default:
        return Icons.list;
    }
  }

  Color get _color {
    switch (widget.filterType) {
      case 'known':
        return Colors.green;
      case 'bookmarked':
        return Colors.orange;
      case 'studied':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 24),
            const SizedBox(width: 8),
            Text(_title),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/mypage'),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
          ],
        ),
      );
    }

    if (_words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '$_title가 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '책을 읽고 단어를 학습해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Sort by last studied date (most recent first)
    _words.sort((a, b) {
      if (a.lastStudiedAt == null && b.lastStudiedAt == null) return 0;
      if (a.lastStudiedAt == null) return 1;
      if (b.lastStudiedAt == null) return -1;
      return b.lastStudiedAt!.compareTo(a.lastStudiedAt!);
    });

    return Column(
            children: [
              // Header with count
              Container(
                padding: const EdgeInsets.all(16),
                color: _color.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(_icon, color: _color),
                    const SizedBox(width: 12),
                    Text(
                      '총 ${_words.length}개',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _color,
                      ),
                    ),
                  ],
                ),
              ),
              // Word List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    final word = _words[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _color.withOpacity(0.2),
                          child: Icon(_icon, color: _color, size: 20),
                        ),
                        title: Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (word.isKnown)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                          size: 12, color: Colors.green[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '알고있음',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (word.isBookmarked) ...[
                                  if (word.isKnown) const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bookmark,
                                          size: 12, color: Colors.orange[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '북마크',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (word.studyCount != null && word.studyCount! > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '학습 ${word.studyCount}회',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (word.lastStudiedAt != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '최근: ${_formatDate(word.lastStudiedAt!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}분 전';
      }
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${date.year}.${date.month}.${date.day}';
    }
  }
}
