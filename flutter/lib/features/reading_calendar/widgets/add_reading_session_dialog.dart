import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/book.dart';
import '../../../models/reading_session.dart';
import '../services/reading_session_service.dart';
import '../providers/reading_session_provider.dart';
import '../../../presentation/providers/reading_status_provider.dart';

class AddReadingSessionDialog extends ConsumerStatefulWidget {
  final Book? book; // null이면 책 선택 가능, 값이 있으면 해당 책으로 고정

  const AddReadingSessionDialog({
    super.key,
    this.book,
  });

  @override
  ConsumerState<AddReadingSessionDialog> createState() =>
      _AddReadingSessionDialogState();
}

class _AddReadingSessionDialogState
    extends ConsumerState<AddReadingSessionDialog> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  final _readingMinutesController = TextEditingController(text: '30');
  final _pagesReadController = TextEditingController(text: '10');
  final _notesController = TextEditingController();
  String _status = 'reading'; // 'reading' or 'completed'

  bool _isLoading = false;

  @override
  void dispose() {
    _readingMinutesController.dispose();
    _pagesReadController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('책을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Safely parse integers with error handling
      final pagesText = _pagesReadController.text.trim();
      final minutesText = _readingMinutesController.text.trim();

      final pages = int.tryParse(pagesText);
      final minutes = int.tryParse(minutesText);

      if (pages == null || minutes == null) {
        throw Exception('숫자를 올바르게 입력해주세요');
      }

      final request = ReadingSessionRequest(
        isbn: widget.book!.isbn,
        sessionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        pagesRead: pages,
        readingMinutes: minutes,
        notes: _notesController.text.trim(),
        status: _status,
      );

      final service = ref.read(readingSessionServiceProvider);
      await service.saveSession(request);

      // Refresh the reading sessions data
      ref.invalidate(monthlyReadingSessionsProvider);
      ref.invalidate(readingHistoryProvider);

      // Refresh reading status for home screen
      ref.read(readingStatusProvider.notifier).loadHistory();

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('독서 기록이 저장되었습니다!'),
            backgroundColor: Colors.green,
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('독서 기록 추가'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 정보 (있는 경우)
              if (widget.book != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.book, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.book!.author,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 날짜 선택
              const Text(
                '날짜',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(DateFormat('yyyy년 MM월 dd일').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 독서 시간
              const Text(
                '독서 시간 (분)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _readingMinutesController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '예: 30',
                  suffixText: '분',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '독서 시간을 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 읽은 페이지
              const Text(
                '읽은 페이지',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pagesReadController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '예: 10',
                  suffixText: '쪽',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '읽은 페이지를 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 상태 선택 (읽는중 / 완료)
              const Text(
                '상태',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('읽는중'),
                      value: 'reading',
                      groupValue: _status,
                      onChanged: (value) {
                        setState(() => _status = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('완료'),
                      value: 'completed',
                      groupValue: _status,
                      onChanged: (value) {
                        setState(() => _status = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 메모 (선택사항)
              const Text(
                '메모 (선택사항)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '독서 기록에 대한 메모를 남겨보세요',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSession,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('저장'),
        ),
      ],
    );
  }
}
