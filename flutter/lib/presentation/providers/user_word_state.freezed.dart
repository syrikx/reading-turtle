// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_word_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserWordState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserWordStateCopyWith<$Res> {
  factory $UserWordStateCopyWith(
          UserWordState value, $Res Function(UserWordState) then) =
      _$UserWordStateCopyWithImpl<$Res, UserWordState>;
}

/// @nodoc
class _$UserWordStateCopyWithImpl<$Res, $Val extends UserWordState>
    implements $UserWordStateCopyWith<$Res> {
  _$UserWordStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$UserWordStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'UserWordState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements UserWordState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$UserWordStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'UserWordState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements UserWordState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<String, UserWordProgress> wordProgress, UserWordStats stats});

  $UserWordStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$UserWordStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordProgress = null,
    Object? stats = null,
  }) {
    return _then(_$LoadedImpl(
      wordProgress: null == wordProgress
          ? _value._wordProgress
          : wordProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, UserWordProgress>,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as UserWordStats,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserWordStatsCopyWith<$Res> get stats {
    return $UserWordStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value));
    });
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
      {required final Map<String, UserWordProgress> wordProgress,
      required this.stats})
      : _wordProgress = wordProgress;

  final Map<String, UserWordProgress> _wordProgress;
  @override
  Map<String, UserWordProgress> get wordProgress {
    if (_wordProgress is EqualUnmodifiableMapView) return _wordProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_wordProgress);
  }

// word -> progress (using word string as key)
  @override
  final UserWordStats stats;

  @override
  String toString() {
    return 'UserWordState.loaded(wordProgress: $wordProgress, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._wordProgress, _wordProgress) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_wordProgress), stats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(wordProgress, stats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(wordProgress, stats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(wordProgress, stats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements UserWordState {
  const factory _Loaded(
      {required final Map<String, UserWordProgress> wordProgress,
      required final UserWordStats stats}) = _$LoadedImpl;

  Map<String, UserWordProgress>
      get wordProgress; // word -> progress (using word string as key)
  UserWordStats get stats;
  @JsonKey(ignore: true)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$UserWordStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'UserWordState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            Map<String, UserWordProgress> wordProgress, UserWordStats stats)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements UserWordState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserWordProgress {
  int get wordId => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  bool get isKnown =>
      throw _privateConstructorUsedError; // User marked as "I know this word"
  bool get isBookmarked =>
      throw _privateConstructorUsedError; // User saved/bookmarked
  DateTime? get lastStudiedAt => throw _privateConstructorUsedError;
  int? get studyCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserWordProgressCopyWith<UserWordProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserWordProgressCopyWith<$Res> {
  factory $UserWordProgressCopyWith(
          UserWordProgress value, $Res Function(UserWordProgress) then) =
      _$UserWordProgressCopyWithImpl<$Res, UserWordProgress>;
  @useResult
  $Res call(
      {int wordId,
      String word,
      bool isKnown,
      bool isBookmarked,
      DateTime? lastStudiedAt,
      int? studyCount});
}

/// @nodoc
class _$UserWordProgressCopyWithImpl<$Res, $Val extends UserWordProgress>
    implements $UserWordProgressCopyWith<$Res> {
  _$UserWordProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? word = null,
    Object? isKnown = null,
    Object? isBookmarked = null,
    Object? lastStudiedAt = freezed,
    Object? studyCount = freezed,
  }) {
    return _then(_value.copyWith(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      isKnown: null == isKnown
          ? _value.isKnown
          : isKnown // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      studyCount: freezed == studyCount
          ? _value.studyCount
          : studyCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserWordProgressImplCopyWith<$Res>
    implements $UserWordProgressCopyWith<$Res> {
  factory _$$UserWordProgressImplCopyWith(_$UserWordProgressImpl value,
          $Res Function(_$UserWordProgressImpl) then) =
      __$$UserWordProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int wordId,
      String word,
      bool isKnown,
      bool isBookmarked,
      DateTime? lastStudiedAt,
      int? studyCount});
}

/// @nodoc
class __$$UserWordProgressImplCopyWithImpl<$Res>
    extends _$UserWordProgressCopyWithImpl<$Res, _$UserWordProgressImpl>
    implements _$$UserWordProgressImplCopyWith<$Res> {
  __$$UserWordProgressImplCopyWithImpl(_$UserWordProgressImpl _value,
      $Res Function(_$UserWordProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? word = null,
    Object? isKnown = null,
    Object? isBookmarked = null,
    Object? lastStudiedAt = freezed,
    Object? studyCount = freezed,
  }) {
    return _then(_$UserWordProgressImpl(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      isKnown: null == isKnown
          ? _value.isKnown
          : isKnown // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      studyCount: freezed == studyCount
          ? _value.studyCount
          : studyCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$UserWordProgressImpl implements _UserWordProgress {
  const _$UserWordProgressImpl(
      {required this.wordId,
      required this.word,
      required this.isKnown,
      required this.isBookmarked,
      this.lastStudiedAt,
      this.studyCount});

  @override
  final int wordId;
  @override
  final String word;
  @override
  final bool isKnown;
// User marked as "I know this word"
  @override
  final bool isBookmarked;
// User saved/bookmarked
  @override
  final DateTime? lastStudiedAt;
  @override
  final int? studyCount;

  @override
  String toString() {
    return 'UserWordProgress(wordId: $wordId, word: $word, isKnown: $isKnown, isBookmarked: $isBookmarked, lastStudiedAt: $lastStudiedAt, studyCount: $studyCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserWordProgressImpl &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.isKnown, isKnown) || other.isKnown == isKnown) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.lastStudiedAt, lastStudiedAt) ||
                other.lastStudiedAt == lastStudiedAt) &&
            (identical(other.studyCount, studyCount) ||
                other.studyCount == studyCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId, word, isKnown,
      isBookmarked, lastStudiedAt, studyCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserWordProgressImplCopyWith<_$UserWordProgressImpl> get copyWith =>
      __$$UserWordProgressImplCopyWithImpl<_$UserWordProgressImpl>(
          this, _$identity);
}

abstract class _UserWordProgress implements UserWordProgress {
  const factory _UserWordProgress(
      {required final int wordId,
      required final String word,
      required final bool isKnown,
      required final bool isBookmarked,
      final DateTime? lastStudiedAt,
      final int? studyCount}) = _$UserWordProgressImpl;

  @override
  int get wordId;
  @override
  String get word;
  @override
  bool get isKnown;
  @override // User marked as "I know this word"
  bool get isBookmarked;
  @override // User saved/bookmarked
  DateTime? get lastStudiedAt;
  @override
  int? get studyCount;
  @override
  @JsonKey(ignore: true)
  _$$UserWordProgressImplCopyWith<_$UserWordProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserWordStats {
  int get totalWords => throw _privateConstructorUsedError;
  int get knownWords => throw _privateConstructorUsedError;
  int get bookmarkedWords => throw _privateConstructorUsedError;
  int get studiedWords => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserWordStatsCopyWith<UserWordStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserWordStatsCopyWith<$Res> {
  factory $UserWordStatsCopyWith(
          UserWordStats value, $Res Function(UserWordStats) then) =
      _$UserWordStatsCopyWithImpl<$Res, UserWordStats>;
  @useResult
  $Res call(
      {int totalWords, int knownWords, int bookmarkedWords, int studiedWords});
}

/// @nodoc
class _$UserWordStatsCopyWithImpl<$Res, $Val extends UserWordStats>
    implements $UserWordStatsCopyWith<$Res> {
  _$UserWordStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWords = null,
    Object? knownWords = null,
    Object? bookmarkedWords = null,
    Object? studiedWords = null,
  }) {
    return _then(_value.copyWith(
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      knownWords: null == knownWords
          ? _value.knownWords
          : knownWords // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkedWords: null == bookmarkedWords
          ? _value.bookmarkedWords
          : bookmarkedWords // ignore: cast_nullable_to_non_nullable
              as int,
      studiedWords: null == studiedWords
          ? _value.studiedWords
          : studiedWords // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserWordStatsImplCopyWith<$Res>
    implements $UserWordStatsCopyWith<$Res> {
  factory _$$UserWordStatsImplCopyWith(
          _$UserWordStatsImpl value, $Res Function(_$UserWordStatsImpl) then) =
      __$$UserWordStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalWords, int knownWords, int bookmarkedWords, int studiedWords});
}

/// @nodoc
class __$$UserWordStatsImplCopyWithImpl<$Res>
    extends _$UserWordStatsCopyWithImpl<$Res, _$UserWordStatsImpl>
    implements _$$UserWordStatsImplCopyWith<$Res> {
  __$$UserWordStatsImplCopyWithImpl(
      _$UserWordStatsImpl _value, $Res Function(_$UserWordStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWords = null,
    Object? knownWords = null,
    Object? bookmarkedWords = null,
    Object? studiedWords = null,
  }) {
    return _then(_$UserWordStatsImpl(
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      knownWords: null == knownWords
          ? _value.knownWords
          : knownWords // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkedWords: null == bookmarkedWords
          ? _value.bookmarkedWords
          : bookmarkedWords // ignore: cast_nullable_to_non_nullable
              as int,
      studiedWords: null == studiedWords
          ? _value.studiedWords
          : studiedWords // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$UserWordStatsImpl implements _UserWordStats {
  const _$UserWordStatsImpl(
      {required this.totalWords,
      required this.knownWords,
      required this.bookmarkedWords,
      required this.studiedWords});

  @override
  final int totalWords;
  @override
  final int knownWords;
  @override
  final int bookmarkedWords;
  @override
  final int studiedWords;

  @override
  String toString() {
    return 'UserWordStats(totalWords: $totalWords, knownWords: $knownWords, bookmarkedWords: $bookmarkedWords, studiedWords: $studiedWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserWordStatsImpl &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.knownWords, knownWords) ||
                other.knownWords == knownWords) &&
            (identical(other.bookmarkedWords, bookmarkedWords) ||
                other.bookmarkedWords == bookmarkedWords) &&
            (identical(other.studiedWords, studiedWords) ||
                other.studiedWords == studiedWords));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, totalWords, knownWords, bookmarkedWords, studiedWords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserWordStatsImplCopyWith<_$UserWordStatsImpl> get copyWith =>
      __$$UserWordStatsImplCopyWithImpl<_$UserWordStatsImpl>(this, _$identity);
}

abstract class _UserWordStats implements UserWordStats {
  const factory _UserWordStats(
      {required final int totalWords,
      required final int knownWords,
      required final int bookmarkedWords,
      required final int studiedWords}) = _$UserWordStatsImpl;

  @override
  int get totalWords;
  @override
  int get knownWords;
  @override
  int get bookmarkedWords;
  @override
  int get studiedWords;
  @override
  @JsonKey(ignore: true)
  _$$UserWordStatsImplCopyWith<_$UserWordStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
