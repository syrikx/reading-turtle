// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReadingHistory _$ReadingHistoryFromJson(Map<String, dynamic> json) {
  return _ReadingHistory.fromJson(json);
}

/// @nodoc
mixin _$ReadingHistory {
  @JsonKey(name: 'history_id')
  int get historyId => throw _privateConstructorUsedError;
  String get isbn => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  String? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'reading_at')
  String? get readingAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  String? get completedAt => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String? get img => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pages')
  int? get totalPages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadingHistoryCopyWith<ReadingHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingHistoryCopyWith<$Res> {
  factory $ReadingHistoryCopyWith(
          ReadingHistory value, $Res Function(ReadingHistory) then) =
      _$ReadingHistoryCopyWithImpl<$Res, ReadingHistory>;
  @useResult
  $Res call(
      {@JsonKey(name: 'history_id') int historyId,
      String isbn,
      String status,
      @JsonKey(name: 'started_at') String? startedAt,
      @JsonKey(name: 'reading_at') String? readingAt,
      @JsonKey(name: 'completed_at') String? completedAt,
      String title,
      String author,
      String? img,
      @JsonKey(name: 'total_pages') int? totalPages});
}

/// @nodoc
class _$ReadingHistoryCopyWithImpl<$Res, $Val extends ReadingHistory>
    implements $ReadingHistoryCopyWith<$Res> {
  _$ReadingHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? historyId = null,
    Object? isbn = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? readingAt = freezed,
    Object? completedAt = freezed,
    Object? title = null,
    Object? author = null,
    Object? img = freezed,
    Object? totalPages = freezed,
  }) {
    return _then(_value.copyWith(
      historyId: null == historyId
          ? _value.historyId
          : historyId // ignore: cast_nullable_to_non_nullable
              as int,
      isbn: null == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      readingAt: freezed == readingAt
          ? _value.readingAt
          : readingAt // ignore: cast_nullable_to_non_nullable
              as String?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      img: freezed == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPages: freezed == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReadingHistoryImplCopyWith<$Res>
    implements $ReadingHistoryCopyWith<$Res> {
  factory _$$ReadingHistoryImplCopyWith(_$ReadingHistoryImpl value,
          $Res Function(_$ReadingHistoryImpl) then) =
      __$$ReadingHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'history_id') int historyId,
      String isbn,
      String status,
      @JsonKey(name: 'started_at') String? startedAt,
      @JsonKey(name: 'reading_at') String? readingAt,
      @JsonKey(name: 'completed_at') String? completedAt,
      String title,
      String author,
      String? img,
      @JsonKey(name: 'total_pages') int? totalPages});
}

/// @nodoc
class __$$ReadingHistoryImplCopyWithImpl<$Res>
    extends _$ReadingHistoryCopyWithImpl<$Res, _$ReadingHistoryImpl>
    implements _$$ReadingHistoryImplCopyWith<$Res> {
  __$$ReadingHistoryImplCopyWithImpl(
      _$ReadingHistoryImpl _value, $Res Function(_$ReadingHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? historyId = null,
    Object? isbn = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? readingAt = freezed,
    Object? completedAt = freezed,
    Object? title = null,
    Object? author = null,
    Object? img = freezed,
    Object? totalPages = freezed,
  }) {
    return _then(_$ReadingHistoryImpl(
      historyId: null == historyId
          ? _value.historyId
          : historyId // ignore: cast_nullable_to_non_nullable
              as int,
      isbn: null == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      readingAt: freezed == readingAt
          ? _value.readingAt
          : readingAt // ignore: cast_nullable_to_non_nullable
              as String?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      img: freezed == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPages: freezed == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadingHistoryImpl implements _ReadingHistory {
  const _$ReadingHistoryImpl(
      {@JsonKey(name: 'history_id') required this.historyId,
      required this.isbn,
      required this.status,
      @JsonKey(name: 'started_at') this.startedAt,
      @JsonKey(name: 'reading_at') this.readingAt,
      @JsonKey(name: 'completed_at') this.completedAt,
      required this.title,
      required this.author,
      this.img,
      @JsonKey(name: 'total_pages') this.totalPages});

  factory _$ReadingHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingHistoryImplFromJson(json);

  @override
  @JsonKey(name: 'history_id')
  final int historyId;
  @override
  final String isbn;
  @override
  final String status;
  @override
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @override
  @JsonKey(name: 'reading_at')
  final String? readingAt;
  @override
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @override
  final String title;
  @override
  final String author;
  @override
  final String? img;
  @override
  @JsonKey(name: 'total_pages')
  final int? totalPages;

  @override
  String toString() {
    return 'ReadingHistory(historyId: $historyId, isbn: $isbn, status: $status, startedAt: $startedAt, readingAt: $readingAt, completedAt: $completedAt, title: $title, author: $author, img: $img, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingHistoryImpl &&
            (identical(other.historyId, historyId) ||
                other.historyId == historyId) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.readingAt, readingAt) ||
                other.readingAt == readingAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.img, img) || other.img == img) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, historyId, isbn, status,
      startedAt, readingAt, completedAt, title, author, img, totalPages);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingHistoryImplCopyWith<_$ReadingHistoryImpl> get copyWith =>
      __$$ReadingHistoryImplCopyWithImpl<_$ReadingHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingHistoryImplToJson(
      this,
    );
  }
}

abstract class _ReadingHistory implements ReadingHistory {
  const factory _ReadingHistory(
          {@JsonKey(name: 'history_id') required final int historyId,
          required final String isbn,
          required final String status,
          @JsonKey(name: 'started_at') final String? startedAt,
          @JsonKey(name: 'reading_at') final String? readingAt,
          @JsonKey(name: 'completed_at') final String? completedAt,
          required final String title,
          required final String author,
          final String? img,
          @JsonKey(name: 'total_pages') final int? totalPages}) =
      _$ReadingHistoryImpl;

  factory _ReadingHistory.fromJson(Map<String, dynamic> json) =
      _$ReadingHistoryImpl.fromJson;

  @override
  @JsonKey(name: 'history_id')
  int get historyId;
  @override
  String get isbn;
  @override
  String get status;
  @override
  @JsonKey(name: 'started_at')
  String? get startedAt;
  @override
  @JsonKey(name: 'reading_at')
  String? get readingAt;
  @override
  @JsonKey(name: 'completed_at')
  String? get completedAt;
  @override
  String get title;
  @override
  String get author;
  @override
  String? get img;
  @override
  @JsonKey(name: 'total_pages')
  int? get totalPages;
  @override
  @JsonKey(ignore: true)
  _$$ReadingHistoryImplCopyWith<_$ReadingHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
