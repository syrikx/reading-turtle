// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordModelImpl _$$WordModelImplFromJson(Map<String, dynamic> json) =>
    _$WordModelImpl(
      word: json['word'] as String,
      wordOrder: (json['word_order'] as num).toInt(),
      wordId: (json['word_id'] as num?)?.toInt(),
      definition: json['definition'] as String?,
      exampleSentence: json['example_sentence'] as String?,
      minBtLevel: const _StringToNumConverter().fromJson(json['min_bt_level']),
      minLexile: const _StringToNumConverter().fromJson(json['min_lexile']),
      isKnown: json['is_known'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      studyCount: (json['study_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WordModelImplToJson(_$WordModelImpl instance) =>
    <String, dynamic>{
      'word': instance.word,
      'word_order': instance.wordOrder,
      'word_id': instance.wordId,
      'definition': instance.definition,
      'example_sentence': instance.exampleSentence,
      'min_bt_level': const _StringToNumConverter().toJson(instance.minBtLevel),
      'min_lexile': const _StringToNumConverter().toJson(instance.minLexile),
      'is_known': instance.isKnown,
      'is_bookmarked': instance.isBookmarked,
      'study_count': instance.studyCount,
    };
