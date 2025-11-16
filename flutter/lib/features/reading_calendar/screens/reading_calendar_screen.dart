import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/reading_session.dart';
import '../providers/reading_session_provider.dart';
import 'package:intl/intl.dart';

class ReadingCalendarScreen extends ConsumerStatefulWidget {
  const ReadingCalendarScreen({super.key});

  @override
  ConsumerState<ReadingCalendarScreen> createState() =>
      _ReadingCalendarScreenState();
}

class _ReadingCalendarScreenState extends ConsumerState<ReadingCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(monthlyReadingSessionsProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 캘린더'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              context.go('/reading-calendar/monthly');
            },
            tooltip: '월 캘린더 보기',
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(monthlyReadingSessionsProvider(_selectedDate)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (sessions) => _buildSessionsView(sessions),
      ),
    );
  }

  Widget _buildSessionsView(List<ReadingSession> sessions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month selector
          _buildMonthSelector(),
          const SizedBox(height: 16),

          // Stats card
          _buildStatsCard(sessions),
          const SizedBox(height: 24),

          // Sessions list
          const Text(
            '📖 독서 기록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (sessions.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '이번 달 독서 기록이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...sessions.map((session) => _buildSessionCard(session)),

          const SizedBox(height: 24),

          // Add session button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: 책 선택 기능 추가 필요
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('책 검색 화면에서 "독서 기록" 버튼을 눌러 기록을 추가해주세요'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.add_circle),
              label: const Text(
                '독서 기록 추가하기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month - 1,
                  );
                });
              },
            ),
            Text(
              '${_selectedDate.year}년 ${_selectedDate.month}월',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<ReadingSession> sessions) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.readingMinutes,
    );

    // Count unique days with reading sessions
    final uniqueDays = sessions.map((s) => s.sessionDate).toSet().length;

    return Card(
      elevation: 2,
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$uniqueDays일',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '독서한 날',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.teal[200],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalMinutes분',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '총 독서 시간',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(ReadingSession session) {
    final date = DateTime.parse(session.sessionDate);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.teal[100],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
              Text(
                '${date.month}월',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.teal[600],
                ),
              ),
            ],
          ),
        ),
        title: Text(
          session.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${session.readingMinutes}분 독서 • ${session.pagesRead}쪽'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // TODO: Navigate to session detail/edit screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${session.title} 상세보기'),
              backgroundColor: Colors.teal,
            ),
          );
        },
      ),
    );
  }
}
