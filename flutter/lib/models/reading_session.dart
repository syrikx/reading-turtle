import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_session.freezed.dart';
part 'reading_session.g.dart';

@freezed
class ReadingSession with _$ReadingSession {
  const factory ReadingSession({
    required int sessionId,
    required String sessionDate,
    required int pagesRead,
    required int readingMinutes,
    required String notes,
    @Default('reading') String status,
    required String isbn,
    required String title,
    required String author,
    String? img,
    int? totalPages,
  }) = _ReadingSession;

  factory ReadingSession.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionFromJson(json);
}

@freezed
class ReadingSessionRequest with _$ReadingSessionRequest {
  const factory ReadingSessionRequest({
    required String isbn,
    required String sessionDate,
    int? pagesRead,
    int? readingMinutes,
    String? notes,
    @Default('reading') String status,
  }) = _ReadingSessionRequest;

  factory ReadingSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionRequestFromJson(json);
}
