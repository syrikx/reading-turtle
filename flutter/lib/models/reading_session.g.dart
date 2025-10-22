// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadingSessionImpl _$$ReadingSessionImplFromJson(Map<String, dynamic> json) =>
    _$ReadingSessionImpl(
      sessionId: (json['sessionId'] as num).toInt(),
      sessionDate: json['sessionDate'] as String,
      pagesRead: (json['pagesRead'] as num).toInt(),
      readingMinutes: (json['readingMinutes'] as num).toInt(),
      notes: json['notes'] as String,
      isbn: json['isbn'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      img: json['img'] as String?,
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ReadingSessionImplToJson(
        _$ReadingSessionImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionDate': instance.sessionDate,
      'pagesRead': instance.pagesRead,
      'readingMinutes': instance.readingMinutes,
      'notes': instance.notes,
      'isbn': instance.isbn,
      'title': instance.title,
      'author': instance.author,
      'img': instance.img,
      'totalPages': instance.totalPages,
    };

_$ReadingSessionRequestImpl _$$ReadingSessionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ReadingSessionRequestImpl(
      isbn: json['isbn'] as String,
      sessionDate: json['sessionDate'] as String,
      pagesRead: (json['pagesRead'] as num?)?.toInt(),
      readingMinutes: (json['readingMinutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ReadingSessionRequestImplToJson(
        _$ReadingSessionRequestImpl instance) =>
    <String, dynamic>{
      'isbn': instance.isbn,
      'sessionDate': instance.sessionDate,
      'pagesRead': instance.pagesRead,
      'readingMinutes': instance.readingMinutes,
      'notes': instance.notes,
    };
