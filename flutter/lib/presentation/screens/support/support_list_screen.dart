import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/support_provider.dart';

class SupportListScreen extends ConsumerStatefulWidget {
  const SupportListScreen({super.key});

  @override
  ConsumerState<SupportListScreen> createState() => _SupportListScreenState();
}

class _SupportListScreenState extends ConsumerState<SupportListScreen> {
  @override
  void initState() {
    super.initState();
    // Load posts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportProvider.notifier).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📞 고객센터'),
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
        loaded: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyState();
          }
          return _buildPostsList(posts);
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
                  ref.read(supportProvider.notifier).loadPosts();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/support/new'),
        icon: const Icon(Icons.add),
        label: const Text('문의하기'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '문의 내역이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '궁금한 점이 있으시면 문의해주세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(posts) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(supportProvider.notifier).loadPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.go('/support/${post.postId}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusChip(post.status),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(post.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        if (post.replyCount != null && post.replyCount! > 0) ...[
                          Icon(Icons.comment, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${post.replyCount}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'open':
        color = Colors.orange;
        label = '대기중';
        break;
      case 'answered':
        color = Colors.green;
        label = '답변완료';
        break;
      case 'closed':
        color = Colors.grey;
        label = '종료';
        break;
      default:
        color = Colors.blue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
