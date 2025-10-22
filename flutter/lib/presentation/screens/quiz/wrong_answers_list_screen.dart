import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/api/quiz_api_service.dart';
import '../../providers/auth_provider.dart';

class WrongAnswersListScreen extends ConsumerStatefulWidget {
  const WrongAnswersListScreen({super.key});

  @override
  ConsumerState<WrongAnswersListScreen> createState() =>
      _WrongAnswersListScreenState();
}

class _WrongAnswersListScreenState
    extends ConsumerState<WrongAnswersListScreen> {
  List<Map<String, dynamic>> _wrongAnswers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWrongAnswers();
  }

  Future<void> _loadWrongAnswers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final quizService = QuizApiService(apiClient);

      final response = await quizService.getWrongAnswersList();
      final data = response['data'] as List;

      setState(() {
        _wrongAnswers = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteWrongAnswer(int wordId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final quizService = QuizApiService(apiClient);

      await quizService.deleteWrongAnswer(wordId: wordId);

      setState(() {
        _wrongAnswers.removeWhere((item) => item['word_id'] == wordId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _retryQuiz() {
    if (_wrongAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오답 노트가 비어있습니다')),
      );
      return;
    }

    final count = _wrongAnswers.length > 20 ? 20 : _wrongAnswers.length;
    context.go('/quiz-wrong-answers?count=$count');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 24),
            SizedBox(width: 8),
            Text('오답 노트'),
          ],
        ),
        actions: [
          if (_wrongAnswers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadWrongAnswers,
              tooltip: '새로고침',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _wrongAnswers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _retryQuiz,
              icon: const Icon(Icons.quiz),
              label: const Text('다시 시험보기'),
              backgroundColor: Colors.deepPurple,
            )
          : null,
    );
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
              onPressed: _loadWrongAnswers,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_wrongAnswers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            const Text(
              '오답 노트가 비어있습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '모든 문제를 맞혔거나 아직 시험을 보지 않았습니다',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/quiz-config'),
              icon: const Icon(Icons.quiz),
              label: const Text('시험 보러 가기'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                '총 ${_wrongAnswers.length}개의 틀린 단어',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _wrongAnswers.length,
            itemBuilder: (context, index) {
              final item = _wrongAnswers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    child: Text(
                      '${item['wrong_count'] ?? 1}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    item['word'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['definition'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item['definition'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item['quiz_type'] != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getQuizTypeLabel(item['quiz_type'] as String?),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _formatDate(item['last_wrong_at'] as String?),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteDialog(item['word_id'] as int),
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

  String _getQuizTypeLabel(String? quizType) {
    switch (quizType) {
      case 'level':
        return '레벨';
      case 'known':
        return '아는 단어';
      case 'bookmarked':
        return '북마크';
      case 'studied':
        return '학습 단어';
      case 'wrong_answers':
        return '오답 재시험';
      default:
        return '시험';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
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
    } catch (e) {
      return '';
    }
  }

  void _showDeleteDialog(int wordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 단어를 오답 노트에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWrongAnswer(wordId);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
