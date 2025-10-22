// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Quiz {
  int get questionId => throw _privateConstructorUsedError;
  int get questionNumber => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String get choice1 => throw _privateConstructorUsedError;
  String get choice2 => throw _privateConstructorUsedError;
  String get choice3 => throw _privateConstructorUsedError;
  String get choice4 => throw _privateConstructorUsedError;
  int get correctChoiceNumber => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QuizCopyWith<Quiz> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizCopyWith<$Res> {
  factory $QuizCopyWith(Quiz value, $Res Function(Quiz) then) =
      _$QuizCopyWithImpl<$Res, Quiz>;
  @useResult
  $Res call(
      {int questionId,
      int questionNumber,
      String questionText,
      String choice1,
      String choice2,
      String choice3,
      String choice4,
      int correctChoiceNumber,
      String correctAnswer});
}

/// @nodoc
class _$QuizCopyWithImpl<$Res, $Val extends Quiz>
    implements $QuizCopyWith<$Res> {
  _$QuizCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionNumber = null,
    Object? questionText = null,
    Object? choice1 = null,
    Object? choice2 = null,
    Object? choice3 = null,
    Object? choice4 = null,
    Object? correctChoiceNumber = null,
    Object? correctAnswer = null,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as int,
      questionNumber: null == questionNumber
          ? _value.questionNumber
          : questionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      choice1: null == choice1
          ? _value.choice1
          : choice1 // ignore: cast_nullable_to_non_nullable
              as String,
      choice2: null == choice2
          ? _value.choice2
          : choice2 // ignore: cast_nullable_to_non_nullable
              as String,
      choice3: null == choice3
          ? _value.choice3
          : choice3 // ignore: cast_nullable_to_non_nullable
              as String,
      choice4: null == choice4
          ? _value.choice4
          : choice4 // ignore: cast_nullable_to_non_nullable
              as String,
      correctChoiceNumber: null == correctChoiceNumber
          ? _value.correctChoiceNumber
          : correctChoiceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizImplCopyWith<$Res> implements $QuizCopyWith<$Res> {
  factory _$$QuizImplCopyWith(
          _$QuizImpl value, $Res Function(_$QuizImpl) then) =
      __$$QuizImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int questionId,
      int questionNumber,
      String questionText,
      String choice1,
      String choice2,
      String choice3,
      String choice4,
      int correctChoiceNumber,
      String correctAnswer});
}

/// @nodoc
class __$$QuizImplCopyWithImpl<$Res>
    extends _$QuizCopyWithImpl<$Res, _$QuizImpl>
    implements _$$QuizImplCopyWith<$Res> {
  __$$QuizImplCopyWithImpl(_$QuizImpl _value, $Res Function(_$QuizImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionNumber = null,
    Object? questionText = null,
    Object? choice1 = null,
    Object? choice2 = null,
    Object? choice3 = null,
    Object? choice4 = null,
    Object? correctChoiceNumber = null,
    Object? correctAnswer = null,
  }) {
    return _then(_$QuizImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as int,
      questionNumber: null == questionNumber
          ? _value.questionNumber
          : questionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      choice1: null == choice1
          ? _value.choice1
          : choice1 // ignore: cast_nullable_to_non_nullable
              as String,
      choice2: null == choice2
          ? _value.choice2
          : choice2 // ignore: cast_nullable_to_non_nullable
              as String,
      choice3: null == choice3
          ? _value.choice3
          : choice3 // ignore: cast_nullable_to_non_nullable
              as String,
      choice4: null == choice4
          ? _value.choice4
          : choice4 // ignore: cast_nullable_to_non_nullable
              as String,
      correctChoiceNumber: null == correctChoiceNumber
          ? _value.correctChoiceNumber
          : correctChoiceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$QuizImpl implements _Quiz {
  const _$QuizImpl(
      {required this.questionId,
      required this.questionNumber,
      required this.questionText,
      required this.choice1,
      required this.choice2,
      required this.choice3,
      required this.choice4,
      required this.correctChoiceNumber,
      required this.correctAnswer});

  @override
  final int questionId;
  @override
  final int questionNumber;
  @override
  final String questionText;
  @override
  final String choice1;
  @override
  final String choice2;
  @override
  final String choice3;
  @override
  final String choice4;
  @override
  final int correctChoiceNumber;
  @override
  final String correctAnswer;

  @override
  String toString() {
    return 'Quiz(questionId: $questionId, questionNumber: $questionNumber, questionText: $questionText, choice1: $choice1, choice2: $choice2, choice3: $choice3, choice4: $choice4, correctChoiceNumber: $correctChoiceNumber, correctAnswer: $correctAnswer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.choice1, choice1) || other.choice1 == choice1) &&
            (identical(other.choice2, choice2) || other.choice2 == choice2) &&
            (identical(other.choice3, choice3) || other.choice3 == choice3) &&
            (identical(other.choice4, choice4) || other.choice4 == choice4) &&
            (identical(other.correctChoiceNumber, correctChoiceNumber) ||
                other.correctChoiceNumber == correctChoiceNumber) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      questionNumber,
      questionText,
      choice1,
      choice2,
      choice3,
      choice4,
      correctChoiceNumber,
      correctAnswer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizImplCopyWith<_$QuizImpl> get copyWith =>
      __$$QuizImplCopyWithImpl<_$QuizImpl>(this, _$identity);
}

abstract class _Quiz implements Quiz {
  const factory _Quiz(
      {required final int questionId,
      required final int questionNumber,
      required final String questionText,
      required final String choice1,
      required final String choice2,
      required final String choice3,
      required final String choice4,
      required final int correctChoiceNumber,
      required final String correctAnswer}) = _$QuizImpl;

  @override
  int get questionId;
  @override
  int get questionNumber;
  @override
  String get questionText;
  @override
  String get choice1;
  @override
  String get choice2;
  @override
  String get choice3;
  @override
  String get choice4;
  @override
  int get correctChoiceNumber;
  @override
  String get correctAnswer;
  @override
  @JsonKey(ignore: true)
  _$$QuizImplCopyWith<_$QuizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QuizResponse {
  Book get book => throw _privateConstructorUsedError;
  List<Quiz> get quizzes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QuizResponseCopyWith<QuizResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizResponseCopyWith<$Res> {
  factory $QuizResponseCopyWith(
          QuizResponse value, $Res Function(QuizResponse) then) =
      _$QuizResponseCopyWithImpl<$Res, QuizResponse>;
  @useResult
  $Res call({Book book, List<Quiz> quizzes});

  $BookCopyWith<$Res> get book;
}

/// @nodoc
class _$QuizResponseCopyWithImpl<$Res, $Val extends QuizResponse>
    implements $QuizResponseCopyWith<$Res> {
  _$QuizResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? quizzes = null,
  }) {
    return _then(_value.copyWith(
      book: null == book
          ? _value.book
          : book // ignore: cast_nullable_to_non_nullable
              as Book,
      quizzes: null == quizzes
          ? _value.quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<Quiz>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BookCopyWith<$Res> get book {
    return $BookCopyWith<$Res>(_value.book, (value) {
      return _then(_value.copyWith(book: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuizResponseImplCopyWith<$Res>
    implements $QuizResponseCopyWith<$Res> {
  factory _$$QuizResponseImplCopyWith(
          _$QuizResponseImpl value, $Res Function(_$QuizResponseImpl) then) =
      __$$QuizResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Book book, List<Quiz> quizzes});

  @override
  $BookCopyWith<$Res> get book;
}

/// @nodoc
class __$$QuizResponseImplCopyWithImpl<$Res>
    extends _$QuizResponseCopyWithImpl<$Res, _$QuizResponseImpl>
    implements _$$QuizResponseImplCopyWith<$Res> {
  __$$QuizResponseImplCopyWithImpl(
      _$QuizResponseImpl _value, $Res Function(_$QuizResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? quizzes = null,
  }) {
    return _then(_$QuizResponseImpl(
      book: null == book
          ? _value.book
          : book // ignore: cast_nullable_to_non_nullable
              as Book,
      quizzes: null == quizzes
          ? _value._quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<Quiz>,
    ));
  }
}

/// @nodoc

class _$QuizResponseImpl implements _QuizResponse {
  const _$QuizResponseImpl(
      {required this.book, required final List<Quiz> quizzes})
      : _quizzes = quizzes;

  @override
  final Book book;
  final List<Quiz> _quizzes;
  @override
  List<Quiz> get quizzes {
    if (_quizzes is EqualUnmodifiableListView) return _quizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizzes);
  }

  @override
  String toString() {
    return 'QuizResponse(book: $book, quizzes: $quizzes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizResponseImpl &&
            (identical(other.book, book) || other.book == book) &&
            const DeepCollectionEquality().equals(other._quizzes, _quizzes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, book, const DeepCollectionEquality().hash(_quizzes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizResponseImplCopyWith<_$QuizResponseImpl> get copyWith =>
      __$$QuizResponseImplCopyWithImpl<_$QuizResponseImpl>(this, _$identity);
}

abstract class _QuizResponse implements QuizResponse {
  const factory _QuizResponse(
      {required final Book book,
      required final List<Quiz> quizzes}) = _$QuizResponseImpl;

  @override
  Book get book;
  @override
  List<Quiz> get quizzes;
  @override
  @JsonKey(ignore: true)
  _$$QuizResponseImplCopyWith<_$QuizResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
