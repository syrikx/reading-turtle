// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WordState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Word> get words => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  int? get wordCount => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WordStateCopyWith<WordState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordStateCopyWith<$Res> {
  factory $WordStateCopyWith(WordState value, $Res Function(WordState) then) =
      _$WordStateCopyWithImpl<$Res, WordState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<Word> words,
      String? isbn,
      int? wordCount,
      String? error});
}

/// @nodoc
class _$WordStateCopyWithImpl<$Res, $Val extends WordState>
    implements $WordStateCopyWith<$Res> {
  _$WordStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? words = null,
    Object? isbn = freezed,
    Object? wordCount = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      words: null == words
          ? _value.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<Word>,
      isbn: freezed == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String?,
      wordCount: freezed == wordCount
          ? _value.wordCount
          : wordCount // ignore: cast_nullable_to_non_nullable
              as int?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordStateImplCopyWith<$Res>
    implements $WordStateCopyWith<$Res> {
  factory _$$WordStateImplCopyWith(
          _$WordStateImpl value, $Res Function(_$WordStateImpl) then) =
      __$$WordStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<Word> words,
      String? isbn,
      int? wordCount,
      String? error});
}

/// @nodoc
class __$$WordStateImplCopyWithImpl<$Res>
    extends _$WordStateCopyWithImpl<$Res, _$WordStateImpl>
    implements _$$WordStateImplCopyWith<$Res> {
  __$$WordStateImplCopyWithImpl(
      _$WordStateImpl _value, $Res Function(_$WordStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? words = null,
    Object? isbn = freezed,
    Object? wordCount = freezed,
    Object? error = freezed,
  }) {
    return _then(_$WordStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      words: null == words
          ? _value._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<Word>,
      isbn: freezed == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String?,
      wordCount: freezed == wordCount
          ? _value.wordCount
          : wordCount // ignore: cast_nullable_to_non_nullable
              as int?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WordStateImpl implements _WordState {
  const _$WordStateImpl(
      {this.isLoading = false,
      final List<Word> words = const [],
      this.isbn,
      this.wordCount,
      this.error})
      : _words = words;

  @override
  @JsonKey()
  final bool isLoading;
  final List<Word> _words;
  @override
  @JsonKey()
  List<Word> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  @override
  final String? isbn;
  @override
  final int? wordCount;
  @override
  final String? error;

  @override
  String toString() {
    return 'WordState(isLoading: $isLoading, words: $words, isbn: $isbn, wordCount: $wordCount, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._words, _words) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.wordCount, wordCount) ||
                other.wordCount == wordCount) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading,
      const DeepCollectionEquality().hash(_words), isbn, wordCount, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordStateImplCopyWith<_$WordStateImpl> get copyWith =>
      __$$WordStateImplCopyWithImpl<_$WordStateImpl>(this, _$identity);
}

abstract class _WordState implements WordState {
  const factory _WordState(
      {final bool isLoading,
      final List<Word> words,
      final String? isbn,
      final int? wordCount,
      final String? error}) = _$WordStateImpl;

  @override
  bool get isLoading;
  @override
  List<Word> get words;
  @override
  String? get isbn;
  @override
  int? get wordCount;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$WordStateImplCopyWith<_$WordStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
