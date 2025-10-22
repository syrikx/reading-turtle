import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/reading_history.dart';
import '../providers/reading_session_provider.dart';

class ReadingCalendarScreen extends ConsumerStatefulWidget {
  const ReadingCalendarScreen({super.key});

  @override
  ConsumerState<ReadingCalendarScreen> createState() =>
      _ReadingCalendarScreenState();
}

class _ReadingCalendarScreenState
    extends ConsumerState<ReadingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(readingHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 달력'),
        elevation: 0,
      ),
      body: historyAsync.when(
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
                onPressed: () => ref.refresh(readingHistoryProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (history) => _buildCalendarWithHistory(history),
      ),
    );
  }

  Widget _buildCalendarWithHistory(List<ReadingHistory> history) {
    // Create events map for calendar markers
    final eventsMap = <DateTime, List<ReadingHistory>>{};

    for (final item in history) {
      if (item.startedAt != null) {
        final startDate = DateTime.parse(item.startedAt!);
        final dateKey = DateTime(startDate.year, startDate.month, startDate.day);
        eventsMap.putIfAbsent(dateKey, () => []).add(item);
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar widget
          Card(
            margin: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                final dateKey = DateTime(day.year, day.month, day.day);
                return eventsMap[dateKey] ?? [];
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reading history list (like a timeline/agenda)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '독서 기록',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                if (history.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 독서 기록이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...history.map((item) => _buildHistoryCard(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ReadingHistory item) {
    final startDate = item.startedAt != null
        ? DateTime.parse(item.startedAt!)
        : null;
    final completedDate = item.completedAt != null
        ? DateTime.parse(item.completedAt!)
        : null;

    String dateRange;
    Color statusColor;
    String statusText;

    if (item.status == 'completed' && startDate != null && completedDate != null) {
      dateRange = '${DateFormat('M/d').format(startDate)} - ${DateFormat('M/d').format(completedDate)}';
      statusColor = Colors.green;
      statusText = '완료';
    } else if (item.status == 'reading' && startDate != null) {
      dateRange = '${DateFormat('M/d').format(startDate)} - 읽는 중';
      statusColor = Colors.blue;
      statusText = '읽는 중';
    } else {
      dateRange = item.startedAt != null
          ? DateFormat('M/d').format(DateTime.parse(item.startedAt!))
          : '날짜 미정';
      statusColor = Colors.grey;
      statusText = item.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            if (item.img != null && item.img!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.img!,
                  width: 60,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 85,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.book, size: 32),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.book, size: 32),
              ),

            const SizedBox(width: 12),

            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Author
                  Text(
                    item.author,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date range
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateRange,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
