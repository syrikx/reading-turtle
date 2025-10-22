import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_word_state.freezed.dart';

/// User's word study progress state
@freezed
class UserWordState with _$UserWordState {
  const factory UserWordState.initial() = _Initial;
  const factory UserWordState.loading() = _Loading;
  const factory UserWordState.loaded({
    required Map<String, UserWordProgress> wordProgress, // word -> progress (using word string as key)
    required UserWordStats stats,
  }) = _Loaded;
  const factory UserWordState.error(String message) = _Error;
}

/// Individual word progress for a user
@freezed
class UserWordProgress with _$UserWordProgress {
  const factory UserWordProgress({
    required int wordId,
    required String word,
    required bool isKnown, // User marked as "I know this word"
    required bool isBookmarked, // User saved/bookmarked
    DateTime? lastStudiedAt,
    int? studyCount, // Number of times studied
  }) = _UserWordProgress;

  factory UserWordProgress.fromJson(Map<String, dynamic> json) {
    // Safe integer parsing
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return UserWordProgress(
      wordId: _parseInt(json['word_id']),
      word: json['word'] as String? ?? '',
      isKnown: json['is_known'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      lastStudiedAt: json['last_studied_at'] != null
          ? DateTime.parse(json['last_studied_at'] as String)
          : null,
      studyCount: _parseInt(json['study_count']),
    );
  }
}

/// Statistics for user's word study
@freezed
class UserWordStats with _$UserWordStats {
  const factory UserWordStats({
    required int totalWords,
    required int knownWords,
    required int bookmarkedWords,
    required int studiedWords,
  }) = _UserWordStats;

  factory UserWordStats.fromJson(Map<String, dynamic> json) {
    // API returns counts as strings, so parse them
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return UserWordStats(
      totalWords: _parseInt(json['total_words']),
      knownWords: _parseInt(json['known_words']),
      bookmarkedWords: _parseInt(json['bookmarked_words']),
      studiedWords: _parseInt(json['studied_words']),
    );
  }
}
