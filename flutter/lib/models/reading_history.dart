import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_history.freezed.dart';
part 'reading_history.g.dart';

@freezed
class ReadingHistory with _$ReadingHistory {
  const factory ReadingHistory({
    @JsonKey(name: 'history_id') required int historyId,
    required String isbn,
    required String status,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'reading_at') String? readingAt,
    @JsonKey(name: 'completed_at') String? completedAt,
    required String title,
    required String author,
    String? img,
    @JsonKey(name: 'total_pages') int? totalPages,
  }) = _ReadingHistory;

  factory ReadingHistory.fromJson(Map<String, dynamic> json) =>
      _$ReadingHistoryFromJson(json);
}
