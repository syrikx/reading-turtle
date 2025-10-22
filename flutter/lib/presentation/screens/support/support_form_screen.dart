import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/support_provider.dart';
import '../../providers/support_state.dart';

class SupportFormScreen extends ConsumerStatefulWidget {
  final int? postId; // null for new post, non-null for edit

  const SupportFormScreen({super.key, this.postId});

  @override
  ConsumerState<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends ConsumerState<SupportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isPrivate = false;

  bool get isEditing => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(supportDetailProvider(widget.postId!).notifier).loadPost(widget.postId!);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      ref.listen<SupportDetailState>(
        supportDetailProvider(widget.postId!),
        (previous, next) {
          next.maybeWhen(
            loaded: (post, _) {
              if (_titleController.text.isEmpty) {
                _titleController.text = post.title;
                _contentController.text = post.content;
                _isPrivate = post.isPrivate;
              }
            },
            orElse: () {},
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '문의 수정' : '새 문의'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '내용을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('비공개 글'),
              subtitle: const Text('작성자와 관리자만 볼 수 있습니다'),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEditing ? '수정하기' : '문의하기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (isEditing) {
        await ref.read(supportDetailProvider(widget.postId!).notifier).updatePost(
              postId: widget.postId!,
              title: title,
              content: content,
              isPrivate: _isPrivate,
            );
      } else {
        await ref.read(supportProvider.notifier).createPost(
              title: title,
              content: content,
              isPrivate: _isPrivate,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? '수정되었습니다' : '문의가 등록되었습니다')),
        );
        context.go('/support');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
