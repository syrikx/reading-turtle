import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required String word,
    required int wordOrder,
    int? wordId,
    String? definition,
    String? exampleSentence,
    num? minBtLevel,
    num? minLexile,
    // User progress fields
    @Default(false) bool isKnown,
    @Default(false) bool isBookmarked,
    int? studyCount,
  }) = _Word;
}

@freezed
class WordListResponse with _$WordListResponse {
  const factory WordListResponse({
    required String isbn,
    required int wordCount,
    required List<Word> words,
  }) = _WordListResponse;
}
