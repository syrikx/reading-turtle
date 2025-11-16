import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/api_client.dart';
import '../../../models/reading_session.dart';
import '../../../models/reading_history.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../services/reading_session_service.dart';

// Provider for ReadingSessionService
final readingSessionServiceProvider = Provider<ReadingSessionService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final apiClient = ApiClient(storageService);
  return ReadingSessionService(apiClient);
});

// Provider for all reading history
final readingHistoryProvider = FutureProvider.autoDispose<List<ReadingHistory>>((ref) async {
  final service = ref.read(readingSessionServiceProvider);
  return await service.getAllReadingHistory();
});

// Provider for reading sessions by date
final dateReadingSessionsProvider =
    FutureProvider.autoDispose.family<List<ReadingSession>, String>((ref, date) async {
  final service = ref.read(readingSessionServiceProvider);
  return await service.getDateSessions(date);
});

// State provider for selected date
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

// State provider for focused month (for calendar)
final focusedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider for monthly reading sessions
final monthlyReadingSessionsProvider =
    FutureProvider.autoDispose.family<List<ReadingSession>, DateTime>((ref, date) async {
  final service = ref.read(readingSessionServiceProvider);
  return await service.getMonthSessions(date.year, date.month);
});
