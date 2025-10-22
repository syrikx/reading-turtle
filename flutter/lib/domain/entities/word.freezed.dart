// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Word {
  String get word => throw _privateConstructorUsedError;
  int get wordOrder => throw _privateConstructorUsedError;
  int? get wordId => throw _privateConstructorUsedError;
  String? get definition => throw _privateConstructorUsedError;
  String? get exampleSentence => throw _privateConstructorUsedError;
  num? get minBtLevel => throw _privateConstructorUsedError;
  num? get minLexile =>
      throw _privateConstructorUsedError; // User progress fields
  bool get isKnown => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  int? get studyCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WordCopyWith<Word> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordCopyWith<$Res> {
  factory $WordCopyWith(Word value, $Res Function(Word) then) =
      _$WordCopyWithImpl<$Res, Word>;
  @useResult
  $Res call(
      {String word,
      int wordOrder,
      int? wordId,
      String? definition,
      String? exampleSentence,
      num? minBtLevel,
      num? minLexile,
      bool isKnown,
      bool isBookmarked,
      int? studyCount});
}

/// @nodoc
class _$WordCopyWithImpl<$Res, $Val extends Word>
    implements $WordCopyWith<$Res> {
  _$WordCopyWithImpl(this._value, this._then);

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
abstract class _$$WordImplCopyWith<$Res> implements $WordCopyWith<$Res> {
  factory _$$WordImplCopyWith(
          _$WordImpl value, $Res Function(_$WordImpl) then) =
      __$$WordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      int wordOrder,
      int? wordId,
      String? definition,
      String? exampleSentence,
      num? minBtLevel,
      num? minLexile,
      bool isKnown,
      bool isBookmarked,
      int? studyCount});
}

/// @nodoc
class __$$WordImplCopyWithImpl<$Res>
    extends _$WordCopyWithImpl<$Res, _$WordImpl>
    implements _$$WordImplCopyWith<$Res> {
  __$$WordImplCopyWithImpl(_$WordImpl _value, $Res Function(_$WordImpl) _then)
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
    return _then(_$WordImpl(
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

class _$WordImpl implements _Word {
  const _$WordImpl(
      {required this.word,
      required this.wordOrder,
      this.wordId,
      this.definition,
      this.exampleSentence,
      this.minBtLevel,
      this.minLexile,
      this.isKnown = false,
      this.isBookmarked = false,
      this.studyCount});

  @override
  final String word;
  @override
  final int wordOrder;
  @override
  final int? wordId;
  @override
  final String? definition;
  @override
  final String? exampleSentence;
  @override
  final num? minBtLevel;
  @override
  final num? minLexile;
// User progress fields
  @override
  @JsonKey()
  final bool isKnown;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  final int? studyCount;

  @override
  String toString() {
    return 'Word(word: $word, wordOrder: $wordOrder, wordId: $wordId, definition: $definition, exampleSentence: $exampleSentence, minBtLevel: $minBtLevel, minLexile: $minLexile, isKnown: $isKnown, isBookmarked: $isBookmarked, studyCount: $studyCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordImpl &&
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
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      __$$WordImplCopyWithImpl<_$WordImpl>(this, _$identity);
}

abstract class _Word implements Word {
  const factory _Word(
      {required final String word,
      required final int wordOrder,
      final int? wordId,
      final String? definition,
      final String? exampleSentence,
      final num? minBtLevel,
      final num? minLexile,
      final bool isKnown,
      final bool isBookmarked,
      final int? studyCount}) = _$WordImpl;

  @override
  String get word;
  @override
  int get wordOrder;
  @override
  int? get wordId;
  @override
  String? get definition;
  @override
  String? get exampleSentence;
  @override
  num? get minBtLevel;
  @override
  num? get minLexile;
  @override // User progress fields
  bool get isKnown;
  @override
  bool get isBookmarked;
  @override
  int? get studyCount;
  @override
  @JsonKey(ignore: true)
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WordListResponse {
  String get isbn => throw _privateConstructorUsedError;
  int get wordCount => throw _privateConstructorUsedError;
  List<Word> get words => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WordListResponseCopyWith<WordListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordListResponseCopyWith<$Res> {
  factory $WordListResponseCopyWith(
          WordListResponse value, $Res Function(WordListResponse) then) =
      _$WordListResponseCopyWithImpl<$Res, WordListResponse>;
  @useResult
  $Res call({String isbn, int wordCount, List<Word> words});
}

/// @nodoc
class _$WordListResponseCopyWithImpl<$Res, $Val extends WordListResponse>
    implements $WordListResponseCopyWith<$Res> {
  _$WordListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isbn = null,
    Object? wordCount = null,
    Object? words = null,
  }) {
    return _then(_value.copyWith(
      isbn: null == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String,
      wordCount: null == wordCount
          ? _value.wordCount
          : wordCount // ignore: cast_nullable_to_non_nullable
              as int,
      words: null == words
          ? _value.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<Word>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordListResponseImplCopyWith<$Res>
    implements $WordListResponseCopyWith<$Res> {
  factory _$$WordListResponseImplCopyWith(_$WordListResponseImpl value,
          $Res Function(_$WordListResponseImpl) then) =
      __$$WordListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String isbn, int wordCount, List<Word> words});
}

/// @nodoc
class __$$WordListResponseImplCopyWithImpl<$Res>
    extends _$WordListResponseCopyWithImpl<$Res, _$WordListResponseImpl>
    implements _$$WordListResponseImplCopyWith<$Res> {
  __$$WordListResponseImplCopyWithImpl(_$WordListResponseImpl _value,
      $Res Function(_$WordListResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isbn = null,
    Object? wordCount = null,
    Object? words = null,
  }) {
    return _then(_$WordListResponseImpl(
      isbn: null == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String,
      wordCount: null == wordCount
          ? _value.wordCount
          : wordCount // ignore: cast_nullable_to_non_nullable
              as int,
      words: null == words
          ? _value._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<Word>,
    ));
  }
}

/// @nodoc

class _$WordListResponseImpl implements _WordListResponse {
  const _$WordListResponseImpl(
      {required this.isbn,
      required this.wordCount,
      required final List<Word> words})
      : _words = words;

  @override
  final String isbn;
  @override
  final int wordCount;
  final List<Word> _words;
  @override
  List<Word> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  @override
  String toString() {
    return 'WordListResponse(isbn: $isbn, wordCount: $wordCount, words: $words)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordListResponseImpl &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.wordCount, wordCount) ||
                other.wordCount == wordCount) &&
            const DeepCollectionEquality().equals(other._words, _words));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isbn, wordCount,
      const DeepCollectionEquality().hash(_words));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordListResponseImplCopyWith<_$WordListResponseImpl> get copyWith =>
      __$$WordListResponseImplCopyWithImpl<_$WordListResponseImpl>(
          this, _$identity);
}

abstract class _WordListResponse implements WordListResponse {
  const factory _WordListResponse(
      {required final String isbn,
      required final int wordCount,
      required final List<Word> words}) = _$WordListResponseImpl;

  @override
  String get isbn;
  @override
  int get wordCount;
  @override
  List<Word> get words;
  @override
  @JsonKey(ignore: true)
  _$$WordListResponseImplCopyWith<_$WordListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
