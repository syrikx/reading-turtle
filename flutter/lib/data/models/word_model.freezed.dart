// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WordModel _$WordModelFromJson(Map<String, dynamic> json) {
  return _WordModel.fromJson(json);
}

/// @nodoc
mixin _$WordModel {
  String get word => throw _privateConstructorUsedError;
  @JsonKey(name: 'word_order')
  int get wordOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'word_id')
  int? get wordId => throw _privateConstructorUsedError;
  String? get definition => throw _privateConstructorUsedError;
  @JsonKey(name: 'example_sentence')
  String? get exampleSentence => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_bt_level')
  @_StringToNumConverter()
  num? get minBtLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_lexile')
  @_StringToNumConverter()
  num? get minLexile =>
      throw _privateConstructorUsedError; // User progress fields - not from API, added client-side
  @JsonKey(name: 'is_known')
  bool get isKnown => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_bookmarked')
  bool get isBookmarked => throw _privateConstructorUsedError;
  @JsonKey(name: 'study_count')
  int? get studyCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WordModelCopyWith<WordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordModelCopyWith<$Res> {
  factory $WordModelCopyWith(WordModel value, $Res Function(WordModel) then) =
      _$WordModelCopyWithImpl<$Res, WordModel>;
  @useResult
  $Res call(
      {String word,
      @JsonKey(name: 'word_order') int wordOrder,
      @JsonKey(name: 'word_id') int? wordId,
      String? definition,
      @JsonKey(name: 'example_sentence') String? exampleSentence,
      @JsonKey(name: 'min_bt_level') @_StringToNumConverter() num? minBtLevel,
      @JsonKey(name: 'min_lexile') @_StringToNumConverter() num? minLexile,
      @JsonKey(name: 'is_known') bool isKnown,
      @JsonKey(name: 'is_bookmarked') bool isBookmarked,
      @JsonKey(name: 'study_count') int? studyCount});
}

/// @nodoc
class _$WordModelCopyWithImpl<$Res, $Val extends WordModel>
    implements $WordModelCopyWith<$Res> {
  _$WordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? wordOrder = null,
    Object? wordId = freezed,
    Object? definition = freezed,
    Object? exampleSentence = freezed,
    Object? minBtLevel = freezed,
    Object? minLexile = freezed,
    Object? isKnown = null,
    Object? isBookmarked = null,
    Object? studyCount = freezed,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      wordOrder: null == wordOrder
          ? _value.wordOrder
          : wordOrder // ignore: cast_nullable_to_non_nullable
              as int,
      wordId: freezed == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int?,
      definition: freezed == definition
          ? _value.definition
          : definition // ignore: cast_nullable_to_non_nullable
              as String?,
      exampleSentence: freezed == exampleSentence
          ? _value.exampleSentence
          : exampleSentence // ignore: cast_nullable_to_non_nullable
              as String?,
      minBtLevel: freezed == minBtLevel
          ? _value.minBtLevel
          : minBtLevel // ignore: cast_nullable_to_non_nullable
              as num?,
      minLexile: freezed == minLexile
          ? _value.minLexile
          : minLexile // ignore: cast_nullable_to_non_nullable
              as num?,
      isKnown: null == isKnown
          ? _value.isKnown
          : isKnown // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      studyCount: freezed == studyCount
          ? _value.studyCount
          : studyCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordModelImplCopyWith<$Res>
    implements $WordModelCopyWith<$Res> {
  factory _$$WordModelImplCopyWith(
          _$WordModelImpl value, $Res Function(_$WordModelImpl) then) =
      __$$WordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      @JsonKey(name: 'word_order') int wordOrder,
      @JsonKey(name: 'word_id') int? wordId,
      String? definition,
      @JsonKey(name: 'example_sentence') String? exampleSentence,
      @JsonKey(name: 'min_bt_level') @_StringToNumConverter() num? minBtLevel,
      @JsonKey(name: 'min_lexile') @_StringToNumConverter() num? minLexile,
      @JsonKey(name: 'is_known') bool isKnown,
      @JsonKey(name: 'is_bookmarked') bool isBookmarked,
      @JsonKey(name: 'study_count') int? studyCount});
}

/// @nodoc
class __$$WordModelImplCopyWithImpl<$Res>
    extends _$WordModelCopyWithImpl<$Res, _$WordModelImpl>
    implements _$$WordModelImplCopyWith<$Res> {
  __$$WordModelImplCopyWithImpl(
      _$WordModelImpl _value, $Res Function(_$WordModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? wordOrder = null,
    Object? wordId = freezed,
    Object? definition = freezed,
    Object? exampleSentence = freezed,
    Object? minBtLevel = freezed,
    Object? minLexile = freezed,
    Object? isKnown = null,
    Object? isBookmarked = null,
    Object? studyCount = freezed,
  }) {
    return _then(_$WordModelImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      wordOrder: null == wordOrder
          ? _value.wordOrder
          : wordOrder // ignore: cast_nullable_to_non_nullable
              as int,
      wordId: freezed == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int?,
      definition: freezed == definition
          ? _value.definition
          : definition // ignore: cast_nullable_to_non_nullable
              as String?,
      exampleSentence: freezed == exampleSentence
          ? _value.exampleSentence
          : exampleSentence // ignore: cast_nullable_to_non_nullable
              as String?,
      minBtLevel: freezed == minBtLevel
          ? _value.minBtLevel
          : minBtLevel // ignore: cast_nullable_to_non_nullable
              as num?,
      minLexile: freezed == minLexile
          ? _value.minLexile
          : minLexile // ignore: cast_nullable_to_non_nullable
              as num?,
      isKnown: null == isKnown
          ? _value.isKnown
          : isKnown // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      studyCount: freezed == studyCount
          ? _value.studyCount
          : studyCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WordModelImpl extends _WordModel {
  const _$WordModelImpl(
      {required this.word,
      @JsonKey(name: 'word_order') required this.wordOrder,
      @JsonKey(name: 'word_id') this.wordId,
      this.definition,
      @JsonKey(name: 'example_sentence') this.exampleSentence,
      @JsonKey(name: 'min_bt_level') @_StringToNumConverter() this.minBtLevel,
      @JsonKey(name: 'min_lexile') @_StringToNumConverter() this.minLexile,
      @JsonKey(name: 'is_known') this.isKnown = false,
      @JsonKey(name: 'is_bookmarked') this.isBookmarked = false,
      @JsonKey(name: 'study_count') this.studyCount})
      : super._();

  factory _$WordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordModelImplFromJson(json);

  @override
  final String word;
  @override
  @JsonKey(name: 'word_order')
  final int wordOrder;
  @override
  @JsonKey(name: 'word_id')
  final int? wordId;
  @override
  final String? definition;
  @override
  @JsonKey(name: 'example_sentence')
  final String? exampleSentence;
  @override
  @JsonKey(name: 'min_bt_level')
  @_StringToNumConverter()
  final num? minBtLevel;
  @override
  @JsonKey(name: 'min_lexile')
  @_StringToNumConverter()
  final num? minLexile;
// User progress fields - not from API, added client-side
  @override
  @JsonKey(name: 'is_known')
  final bool isKnown;
  @override
  @JsonKey(name: 'is_bookmarked')
  final bool isBookmarked;
  @override
  @JsonKey(name: 'study_count')
  final int? studyCount;

  @override
  String toString() {
    return 'WordModel(word: $word, wordOrder: $wordOrder, wordId: $wordId, definition: $definition, exampleSentence: $exampleSentence, minBtLevel: $minBtLevel, minLexile: $minLexile, isKnown: $isKnown, isBookmarked: $isBookmarked, studyCount: $studyCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordModelImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.wordOrder, wordOrder) ||
                other.wordOrder == wordOrder) &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.definition, definition) ||
                other.definition == definition) &&
            (identical(other.exampleSentence, exampleSentence) ||
                other.exampleSentence == exampleSentence) &&
            (identical(other.minBtLevel, minBtLevel) ||
                other.minBtLevel == minBtLevel) &&
            (identical(other.minLexile, minLexile) ||
                other.minLexile == minLexile) &&
            (identical(other.isKnown, isKnown) || other.isKnown == isKnown) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.studyCount, studyCount) ||
                other.studyCount == studyCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      word,
      wordOrder,
      wordId,
      definition,
      exampleSentence,
      minBtLevel,
      minLexile,
      isKnown,
      isBookmarked,
      studyCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordModelImplCopyWith<_$WordModelImpl> get copyWith =>
      __$$WordModelImplCopyWithImpl<_$WordModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordModelImplToJson(
      this,
    );
  }
}

abstract class _WordModel extends WordModel {
  const factory _WordModel(
      {required final String word,
      @JsonKey(name: 'word_order') required final int wordOrder,
      @JsonKey(name: 'word_id') final int? wordId,
      final String? definition,
      @JsonKey(name: 'example_sentence') final String? exampleSentence,
      @JsonKey(name: 'min_bt_level')
      @_StringToNumConverter()
      final num? minBtLevel,
      @JsonKey(name: 'min_lexile')
      @_StringToNumConverter()
      final num? minLexile,
      @JsonKey(name: 'is_known') final bool isKnown,
      @JsonKey(name: 'is_bookmarked') final bool isBookmarked,
      @JsonKey(name: 'study_count') final int? studyCount}) = _$WordModelImpl;
  const _WordModel._() : super._();

  factory _WordModel.fromJson(Map<String, dynamic> json) =
      _$WordModelImpl.fromJson;

  @override
  String get word;
  @override
  @JsonKey(name: 'word_order')
  int get wordOrder;
  @override
  @JsonKey(name: 'word_id')
  int? get wordId;
  @override
  String? get definition;
  @override
  @JsonKey(name: 'example_sentence')
  String? get exampleSentence;
  @override
  @JsonKey(name: 'min_bt_level')
  @_StringToNumConverter()
  num? get minBtLevel;
  @override
  @JsonKey(name: 'min_lexile')
  @_StringToNumConverter()
  num? get minLexile;
  @override // User progress fields - not from API, added client-side
  @JsonKey(name: 'is_known')
  bool get isKnown;
  @override
  @JsonKey(name: 'is_bookmarked')
  bool get isBookmarked;
  @override
  @JsonKey(name: 'study_count')
  int? get studyCount;
  @override
  @JsonKey(ignore: true)
  _$$WordModelImplCopyWith<_$WordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
