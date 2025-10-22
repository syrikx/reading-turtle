import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/user_word_api_service.dart';
import 'user_word_state.dart';
import 'auth_provider.dart';

// User Word API Service Provider
final userWordApiServiceProvider = Provider<UserWordApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserWordApiService(apiClient);
});

// User Word Notifier
class UserWordNotifier extends StateNotifier<UserWordState> {
  final UserWordApiService _apiService;

  UserWordNotifier(this._apiService) : super(const UserWordState.initial());

  /// Load user's word progress for a specific book
  Future<void> loadWordProgress(String isbn) async {
    state = const UserWordState.loading();

    try {
      final response = await _apiService.getUserWordProgress(isbn: isbn);
      final progressData = response['data'] as List;

      final Map<String, UserWordProgress> progressMap = {};
      for (var item in progressData) {
        final progress = UserWordProgress.fromJson(item as Map<String, dynamic>);
        // Use word string as key instead of wordId
        progressMap[progress.word] = progress;
      }

      // Get stats
      final statsResponse = await _apiService.getUserWordStats();
      final stats = UserWordStats.fromJson(
        statsResponse['stats'] as Map<String, dynamic>,
      );

      state = UserWordState.loaded(
        wordProgress: progressMap,
        stats: stats,
      );
    } catch (e) {
      state = UserWordState.error(e.toString());
    }
  }

  /// Toggle word known status
  Future<void> toggleKnown(int wordId, String word, bool isKnown) async {
    try {
      await _apiService.toggleWordKnown(
        wordId: wordId,
        isKnown: isKnown,
      );

      // Update local state using word as key
      state.maybeWhen(
        loaded: (wordProgress, stats) {
          final updatedProgress = Map<String, UserWordProgress>.from(wordProgress);

          // Get existing progress or create new
          final existingProgress = updatedProgress[word];
          if (existingProgress != null) {
            updatedProgress[word] = UserWordProgress(
              wordId: wordId,
              word: word,
              isKnown: isKnown,
              isBookmarked: existingProgress.isBookmarked,
              lastStudiedAt: DateTime.now(),
              studyCount: existingProgress.studyCount,
            );
          } else {
            updatedProgress[word] = UserWordProgress(
              wordId: wordId,
              word: word,
              isKnown: isKnown,
              isBookmarked: false,
              lastStudiedAt: DateTime.now(),
              studyCount: 0,
            );
          }

          // Update stats
          final newKnownCount = isKnown
              ? stats.knownWords + 1
              : (stats.knownWords > 0 ? stats.knownWords - 1 : 0);

          state = UserWordState.loaded(
            wordProgress: updatedProgress,
            stats: stats.copyWith(knownWords: newKnownCount),
          );
        },
        orElse: () {},
      );
    } catch (e) {
      // Don't change state on error, just rethrow
      rethrow;
    }
  }

  /// Toggle word bookmark status
  Future<void> toggleBookmark(int wordId, String word, bool isBookmarked) async {
    try {
      await _apiService.toggleWordBookmark(
        wordId: wordId,
        isBookmarked: isBookmarked,
      );

      // Update local state using word as key
      state.maybeWhen(
        loaded: (wordProgress, stats) {
          final updatedProgress = Map<String, UserWordProgress>.from(wordProgress);

          // Get existing progress or create new
          final existingProgress = updatedProgress[word];
          if (existingProgress != null) {
            updatedProgress[word] = UserWordProgress(
              wordId: wordId,
              word: word,
              isKnown: existingProgress.isKnown,
              isBookmarked: isBookmarked,
              lastStudiedAt: DateTime.now(),
              studyCount: existingProgress.studyCount,
            );
          } else {
            updatedProgress[word] = UserWordProgress(
              wordId: wordId,
              word: word,
              isKnown: false,
              isBookmarked: isBookmarked,
              lastStudiedAt: DateTime.now(),
              studyCount: 0,
            );
          }

          // Update stats
          final newBookmarkedCount = isBookmarked
              ? stats.bookmarkedWords + 1
              : (stats.bookmarkedWords > 0 ? stats.bookmarkedWords - 1 : 0);

          state = UserWordState.loaded(
            wordProgress: updatedProgress,
            stats: stats.copyWith(bookmarkedWords: newBookmarkedCount),
          );
        },
        orElse: () {},
      );
    } catch (e) {
      // Don't change state on error, just rethrow
      rethrow;
    }
  }

  /// Record word study
  Future<void> recordStudy(int wordId, String word) async {
    try {
      await _apiService.recordWordStudy(wordId: wordId);

      // Update local state using word as key
      state.maybeWhen(
        loaded: (wordProgress, stats) {
          final updatedProgress = Map<String, UserWordProgress>.from(wordProgress);

          final existingProgress = updatedProgress[word];
          if (existingProgress != null) {
            updatedProgress[word] = UserWordProgress(
              wordId: wordId,
              word: word,
              isKnown: existingProgress.isKnown,
              isBookmarked: existingProgress.isBookmarked,
              lastStudiedAt: DateTime.now(),
              studyCount: (existingProgress.studyCount ?? 0) + 1,
            );
          } else {
            updatedProgress[word] = UserWordProgress(
              wordId: wordId,
              word: word,
              isKnown: false,
              isBookmarked: false,
              lastStudiedAt: DateTime.now(),
              studyCount: 1,
            );
          }

          state = UserWordState.loaded(
            wordProgress: updatedProgress,
            stats: stats,
          );
        },
        orElse: () {},
      );
    } catch (e) {
      // Don't fail silently for study recording
    }
  }

  /// Get progress for a specific word by word string
  UserWordProgress? getWordProgress(String word) {
    return state.maybeWhen(
      loaded: (wordProgress, stats) => wordProgress[word],
      orElse: () => null,
    );
  }

  /// Get stats
  UserWordStats? getStats() {
    return state.maybeWhen(
      loaded: (wordProgress, stats) => stats,
      orElse: () => null,
    );
  }

  /// Load only user word statistics (without specific book progress)
  Future<void> loadStats() async {
    try {
      final statsResponse = await _apiService.getUserWordStats();
      final stats = UserWordStats.fromJson(
        statsResponse['stats'] as Map<String, dynamic>,
      );

      // Preserve existing word progress if available, or use empty map
      final currentProgress = state.maybeWhen(
        loaded: (wordProgress, _) => wordProgress,
        orElse: () => <String, UserWordProgress>{},
      );

      state = UserWordState.loaded(
        wordProgress: currentProgress,
        stats: stats,
      );
    } catch (e) {
      // Don't set error state for stats loading failure
      // Just keep existing state or set initial state
      state.maybeWhen(
        loaded: (_, __) {
          // Keep current state if already loaded
        },
        orElse: () {
          // Set initial state if not loaded
          state = const UserWordState.initial();
        },
      );
    }
  }
}

// User Word Provider
final userWordProvider =
    StateNotifierProvider<UserWordNotifier, UserWordState>((ref) {
  final apiService = ref.watch(userWordApiServiceProvider);
  return UserWordNotifier(apiService);
});
