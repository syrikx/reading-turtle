import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/tutorial_highlight_box.dart';
import 'tutorial_dummy_data.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/constants/storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class CalendarTutorialScreen extends ConsumerStatefulWidget {
  const CalendarTutorialScreen({super.key});

  @override
  ConsumerState<CalendarTutorialScreen> createState() => _CalendarTutorialScreenState();
}

class _CalendarTutorialScreenState extends ConsumerState<CalendarTutorialScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  DateTime _selectedDate = DateTime.now();

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  Future<void> _completeTutorial() async {
    // Mark tutorial as completed
    final storageService = ref.read(storageServiceProvider);
    await storageService.setBool(StorageKeys.hasSeenInteractiveTutorial, true);

    if (!mounted) return;

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('튜토리얼 완료!'),
          ],
        ),
        content: const Text(
          '모든 튜토리얼을 완료했습니다!\n이제 실제 ReadingTurtle을 사용해보세요.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = TutorialDummyData.sampleReadingSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Calendar'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _skipTutorial,
        ),
      ),
      body: Column(
        children: [
          TutorialBanner(
            title: '📅 독서 캘린더',
            description: _getStepDescription(),
            onNext: _nextStep,
            onSkip: _skipTutorial,
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  _currentStep == 1
                      ? TutorialHighlightBox(
                          instructionText: '월을 선택하여 해당 월의 독서 기록을 확인하세요',
                          child: _buildMonthSelector(),
                        )
                      : _buildMonthSelector(),
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

                  ...sessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final session = entry.value;

                    Widget sessionCard = _buildSessionCard(session);

                    if (_currentStep == 2 && index == 0) {
                      return TutorialHighlightBox(
                        instructionText: '날짜별로 읽은 책과 독서 시간을 기록할 수 있어요',
                        child: sessionCard,
                      );
                    } else if (_currentStep == 3 && index == 1) {
                      return TutorialHighlightBox(
                        instructionText: '매일 꾸준히 기록하여 독서 습관을 만들어보세요!',
                        child: sessionCard,
                      );
                    }

                    return sessionCard;
                  }).toList(),

                  const SizedBox(height: 24),

                  // Add session button (demo)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('실제 앱에서는 여기서 독서 기록을 추가할 수 있습니다!'),
                            backgroundColor: Colors.green,
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
            ),
          ),
        ],
      ),
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 1:
        return '매월 독서 기록을 한눈에 확인할 수 있습니다';
      case 2:
        return '날짜별로 읽은 책과 독서 시간을 기록하세요';
      case 3:
        return '꾸준한 기록으로 독서 습관을 만들어가세요!';
      default:
        return '';
    }
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

  Widget _buildStatsCard(List<Map<String, String>> sessions) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + int.parse(session['minutes']!),
    );
    final totalDays = sessions.length;

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
                    '$totalDays일',
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

  Widget _buildSessionCard(Map<String, String> session) {
    final date = DateTime.parse(session['date']!);
    final title = session['title']!;
    final minutes = session['minutes']!;

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
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('$minutes분 독서'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
