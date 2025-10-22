import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/book.dart';

part 'reading_status_state.freezed.dart';

@freezed
class ReadingStatusState with _$ReadingStatusState {
  const factory ReadingStatusState.initial() = _Initial;
  const factory ReadingStatusState.loading() = _Loading;
  const factory ReadingStatusState.loaded({
    required List<Book> readingBooks,
    required List<Book> allBooks,
    ReadingStats? stats,
    @Default(false) bool isUpdating,
    String? currentFilter,
  }) = _Loaded;
  const factory ReadingStatusState.error(String message) = _Error;
}

@freezed
class ReadingStats with _$ReadingStats {
  const factory ReadingStats({
    @Default(0) int readingCount,
    @Default(0) int completedCount,
    @Default(0) int totalCount,
  }) = _ReadingStats;

  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    return ReadingStats(
      readingCount: json['reading_count'] as int? ?? 0,
      completedCount: json['completed_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
