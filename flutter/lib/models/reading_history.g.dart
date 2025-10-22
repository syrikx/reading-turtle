// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadingHistoryImpl _$$ReadingHistoryImplFromJson(Map<String, dynamic> json) =>
    _$ReadingHistoryImpl(
      historyId: (json['history_id'] as num).toInt(),
      isbn: json['isbn'] as String,
      status: json['status'] as String,
      startedAt: json['started_at'] as String?,
      readingAt: json['reading_at'] as String?,
      completedAt: json['completed_at'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      img: json['img'] as String?,
      totalPages: (json['total_pages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ReadingHistoryImplToJson(
        _$ReadingHistoryImpl instance) =>
    <String, dynamic>{
      'history_id': instance.historyId,
      'isbn': instance.isbn,
      'status': instance.status,
      'started_at': instance.startedAt,
      'reading_at': instance.readingAt,
      'completed_at': instance.completedAt,
      'title': instance.title,
      'author': instance.author,
      'img': instance.img,
      'total_pages': instance.totalPages,
    };
