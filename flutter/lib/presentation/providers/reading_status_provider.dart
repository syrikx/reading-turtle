import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/api_client.dart';
import '../../data/api/reading_status_api_service.dart';
import '../../data/models/book_model.dart';
import '../../domain/entities/book.dart';
import 'reading_status_state.dart';

// Import apiClientProvider from auth_provider
import 'auth_provider.dart';

// Reading Status API Service Provider
final readingStatusApiServiceProvider = Provider<ReadingStatusApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReadingStatusApiService(apiClient);
});

// Reading Status Notifier
class ReadingStatusNotifier extends StateNotifier<ReadingStatusState> {
  final ReadingStatusApiService _apiService;

  ReadingStatusNotifier(this._apiService)
      : super(const ReadingStatusState.initial());

  /// Update reading status for a book
  Future<void> updateStatus(String isbn, String status) async {
    // Set updating flag if in loaded state
    state.maybeWhen(
      loaded: (readingBooks, allBooks, stats, _, currentFilter) {
        state = ReadingStatusState.loaded(
          readingBooks: readingBooks,
          allBooks: allBooks,
          stats: stats,
          isUpdating: true,
          currentFilter: currentFilter,
        );
      },
      orElse: () {},
    );

    try {
      await _apiService.updateStatus(isbn: isbn, status: status);

      // Reload history and stats after update
      await loadHistory();
      await loadStats();
    } catch (e) {
      state = ReadingStatusState.error(e.toString());
      rethrow;
    }
  }

  /// Load reading history
  Future<void> loadHistory({String? statusFilter}) async {
    state = const ReadingStatusState.loading();

    try {
      final response = await _apiService.getHistory(status: statusFilter);
      final booksData = response['data'] as List;

      final books = booksData
          .map((json) => BookModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      // Filter reading books (status = reading)
      final readingBooks = books.where((book) =>
        book.status == 'reading'
      ).toList();

      // Preserve stats if we already have them
      ReadingStats? currentStats;
      state.maybeWhen(
        loaded: (_, __, stats, ___, ____) => currentStats = stats,
        orElse: () {},
      );

      state = ReadingStatusState.loaded(
        readingBooks: readingBooks,
        allBooks: books,
        stats: currentStats,
        currentFilter: statusFilter,
      );
    } catch (e) {
      state = ReadingStatusState.error(e.toString());
    }
  }

  /// Load reading statistics
  Future<void> loadStats() async {
    try {
      final response = await _apiService.getStats();
      final statsData = response['stats'] as Map<String, dynamic>;

      final stats = ReadingStats.fromJson(statsData);

      // Update stats in loaded state
      state.maybeWhen(
        loaded: (readingBooks, allBooks, _, isUpdating, currentFilter) {
          state = ReadingStatusState.loaded(
            readingBooks: readingBooks,
            allBooks: allBooks,
            stats: stats,
            isUpdating: isUpdating,
            currentFilter: currentFilter,
          );
        },
        orElse: () {},
      );
    } catch (e) {
      // Don't fail the whole state if stats fail - just ignore
    }
  }

  /// Filter books by status
  void filterByStatus(String? status) {
    loadHistory(statusFilter: status);
  }

  /// Get filtered books based on current filter
  List<Book> get filteredBooks {
    return state.maybeWhen(
      loaded: (readingBooks, allBooks, stats, isUpdating, currentFilter) {
        if (currentFilter == null) {
          return allBooks;
        }
        return allBooks.where((book) => book.status == currentFilter).toList();
      },
      orElse: () => [],
    );
  }
}

// Reading Status Provider
final readingStatusProvider =
    StateNotifierProvider<ReadingStatusNotifier, ReadingStatusState>((ref) {
  final apiService = ref.watch(readingStatusApiServiceProvider);
  return ReadingStatusNotifier(apiService);
});
