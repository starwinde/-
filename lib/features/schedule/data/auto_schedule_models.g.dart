// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_schedule_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutoScheduleRequest _$AutoScheduleRequestFromJson(Map<String, dynamic> json) =>
    _AutoScheduleRequest(
      text: json['text'] as String,
      userLocale: json['user_locale'] as String,
    );

Map<String, dynamic> _$AutoScheduleRequestToJson(
  _AutoScheduleRequest instance,
) => <String, dynamic>{
  'text': instance.text,
  'user_locale': instance.userLocale,
};

_AutoScheduleResponse _$AutoScheduleResponseFromJson(
  Map<String, dynamic> json,
) => _AutoScheduleResponse(
  title: json['title'] as String,
  startTime: json['start_time'] == null
      ? null
      : DateTime.parse(json['start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  category: _categoryFromJson(json['category'] as String),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  confidence: (json['confidence'] as num).toDouble(),
  source: $enumDecode(_$AutoScheduleSourceEnumMap, json['source']),
);

Map<String, dynamic> _$AutoScheduleResponseToJson(
  _AutoScheduleResponse instance,
) => <String, dynamic>{
  'title': instance.title,
  'start_time': instance.startTime?.toIso8601String(),
  'end_time': instance.endTime?.toIso8601String(),
  'category': _categoryToJson(instance.category),
  'tags': instance.tags,
  'confidence': instance.confidence,
  'source': _$AutoScheduleSourceEnumMap[instance.source]!,
};

const _$AutoScheduleSourceEnumMap = {
  AutoScheduleSource.llm: 'llm',
  AutoScheduleSource.preset: 'preset',
};
