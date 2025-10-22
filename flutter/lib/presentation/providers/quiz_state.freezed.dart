// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QuizState {
  bool get isLoading => throw _privateConstructorUsedError;
  Book? get book => throw _privateConstructorUsedError;
  List<Quiz> get quizzes => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<int, int> get userAnswers => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QuizStateCopyWith<QuizState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizStateCopyWith<$Res> {
  factory $QuizStateCopyWith(QuizState value, $Res Function(QuizState) then) =
      _$QuizStateCopyWithImpl<$Res, QuizState>;
  @useResult
  $Res call(
      {bool isLoading,
      Book? book,
      List<Quiz> quizzes,
      String? error,
      Map<int, int> userAnswers});

  $BookCopyWith<$Res>? get book;
}

/// @nodoc
class _$QuizStateCopyWithImpl<$Res, $Val extends QuizState>
    implements $QuizStateCopyWith<$Res> {
  _$QuizStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? book = freezed,
    Object? quizzes = null,
    Object? error = freezed,
    Object? userAnswers = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      book: freezed == book
          ? _value.book
          : book // ignore: cast_nullable_to_non_nullable
              as Book?,
      quizzes: null == quizzes
          ? _value.quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<Quiz>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      userAnswers: null == userAnswers
          ? _value.userAnswers
          : userAnswers // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BookCopyWith<$Res>? get book {
    if (_value.book == null) {
      return null;
    }

    return $BookCopyWith<$Res>(_value.book!, (value) {
      return _then(_value.copyWith(book: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuizStateImplCopyWith<$Res>
    implements $QuizStateCopyWith<$Res> {
  factory _$$QuizStateImplCopyWith(
          _$QuizStateImpl value, $Res Function(_$QuizStateImpl) then) =
      __$$QuizStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      Book? book,
      List<Quiz> quizzes,
      String? error,
      Map<int, int> userAnswers});

  @override
  $BookCopyWith<$Res>? get book;
}

/// @nodoc
class __$$QuizStateImplCopyWithImpl<$Res>
    extends _$QuizStateCopyWithImpl<$Res, _$QuizStateImpl>
    implements _$$QuizStateImplCopyWith<$Res> {
  __$$QuizStateImplCopyWithImpl(
      _$QuizStateImpl _value, $Res Function(_$QuizStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? book = freezed,
    Object? quizzes = null,
    Object? error = freezed,
    Object? userAnswers = null,
  }) {
    return _then(_$QuizStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      book: freezed == book
          ? _value.book
          : book // ignore: cast_nullable_to_non_nullable
              as Book?,
      quizzes: null == quizzes
          ? _value._quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<Quiz>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      userAnswers: null == userAnswers
          ? _value._userAnswers
          : userAnswers // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
    ));
  }
}

/// @nodoc

class _$QuizStateImpl implements _QuizState {
  const _$QuizStateImpl(
      {this.isLoading = false,
      this.book,
      final List<Quiz> quizzes = const [],
      this.error,
      final Map<int, int> userAnswers = const {}})
      : _quizzes = quizzes,
        _userAnswers = userAnswers;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final Book? book;
  final List<Quiz> _quizzes;
  @override
  @JsonKey()
  List<Quiz> get quizzes {
    if (_quizzes is EqualUnmodifiableListView) return _quizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizzes);
  }

  @override
  final String? error;
  final Map<int, int> _userAnswers;
  @override
  @JsonKey()
  Map<int, int> get userAnswers {
    if (_userAnswers is EqualUnmodifiableMapView) return _userAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userAnswers);
  }

  @override
  String toString() {
    return 'QuizState(isLoading: $isLoading, book: $book, quizzes: $quizzes, error: $error, userAnswers: $userAnswers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.book, book) || other.book == book) &&
            const DeepCollectionEquality().equals(other._quizzes, _quizzes) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._userAnswers, _userAnswers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      book,
      const DeepCollectionEquality().hash(_quizzes),
      error,
      const DeepCollectionEquality().hash(_userAnswers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizStateImplCopyWith<_$QuizStateImpl> get copyWith =>
      __$$QuizStateImplCopyWithImpl<_$QuizStateImpl>(this, _$identity);
}

abstract class _QuizState implements QuizState {
  const factory _QuizState(
      {final bool isLoading,
      final Book? book,
      final List<Quiz> quizzes,
      final String? error,
      final Map<int, int> userAnswers}) = _$QuizStateImpl;

  @override
  bool get isLoading;
  @override
  Book? get book;
  @override
  List<Quiz> get quizzes;
  @override
  String? get error;
  @override
  Map<int, int> get userAnswers;
  @override
  @JsonKey(ignore: true)
  _$$QuizStateImplCopyWith<_$QuizStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
