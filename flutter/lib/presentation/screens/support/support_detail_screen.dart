import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/support_provider.dart';

class SupportDetailScreen extends ConsumerStatefulWidget {
  final int postId;

  const SupportDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends ConsumerState<SupportDetailScreen> {
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportDetailProvider(widget.postId).notifier).loadPost(widget.postId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportDetailProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 상세'),
        actions: [
          state.maybeWhen(
            loaded: (post, _) => PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.go('/support/${widget.postId}/edit');
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('정말 이 문의를 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    try {
                      await ref.read(supportProvider.notifier).deletePost(widget.postId);
                      if (context.mounted) {
                        context.go('/support');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('삭제 실패: $e')),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('수정')),
                const PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (post, replies) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPostCard(post),
                  const SizedBox(height: 16),
                  if (replies.isNotEmpty) ...[
                    Text(
                      '답변 (${replies.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...replies.map((reply) => _buildReplyCard(reply)),
                  ],
                ],
              ),
            ),
            _buildReplyInput(),
          ],
        ),
        error: (message) => Center(child: Text('오류: $message')),
      ),
    );
  }

  Widget _buildPostCard(post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(post.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Text(post.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: reply.isAdmin ? Colors.blue[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (reply.isAdmin)
                  const Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue),
                if (reply.isAdmin) const SizedBox(width: 4),
                Text(
                  reply.fullName ?? reply.username ?? 'User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: reply.isAdmin ? Colors.blue : null,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(reply.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply.content),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submitReply,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    try {
      await ref.read(supportDetailProvider(widget.postId).notifier).addReply(
            postId: widget.postId,
            content: content,
          );
      _replyController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성 실패: $e')),
        );
      }
    }
  }
}
