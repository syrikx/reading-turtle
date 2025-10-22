import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/word.dart';

part 'word_model.freezed.dart';
part 'word_model.g.dart';

// Custom converter for String to num
class _StringToNumConverter implements JsonConverter<num?, dynamic> {
  const _StringToNumConverter();

  @override
  num? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  @override
  dynamic toJson(num? value) => value;
}

@freezed
class WordModel with _$WordModel {
  const WordModel._();

  const factory WordModel({
    required String word,
    @JsonKey(name: 'word_order') required int wordOrder,
    @JsonKey(name: 'word_id') int? wordId,
    String? definition,
    @JsonKey(name: 'example_sentence') String? exampleSentence,
    @JsonKey(name: 'min_bt_level') @_StringToNumConverter() num? minBtLevel,
    @JsonKey(name: 'min_lexile') @_StringToNumConverter() num? minLexile,
    // User progress fields - not from API, added client-side
    @Default(false) @JsonKey(name: 'is_known') bool isKnown,
    @Default(false) @JsonKey(name: 'is_bookmarked') bool isBookmarked,
    @JsonKey(name: 'study_count') int? studyCount,
  }) = _WordModel;

  factory WordModel.fromJson(Map<String, dynamic> json) => _$WordModelFromJson(json);

  Word toEntity() {
    return Word(
      word: word,
      wordOrder: wordOrder,
      wordId: wordId,
      definition: definition,
      exampleSentence: exampleSentence,
      minBtLevel: minBtLevel,
      minLexile: minLexile,
      isKnown: isKnown,
      isBookmarked: isBookmarked,
      studyCount: studyCount,
    );
  }
}
