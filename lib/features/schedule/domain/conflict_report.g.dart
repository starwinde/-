// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConflictReport _$ConflictReportFromJson(Map<String, dynamic> json) =>
    _ConflictReport(
      kind: $enumDecode(_$ConflictKindEnumMap, json['kind']),
      indices: (json['indices'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      severity: $enumDecode(_$ConflictSeverityEnumMap, json['severity']),
      message: json['message'] as String,
      existingId: (json['existing_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConflictReportToJson(_ConflictReport instance) =>
    <String, dynamic>{
      'kind': _$ConflictKindEnumMap[instance.kind]!,
      'indices': instance.indices,
      'severity': _$ConflictSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'existing_id': instance.existingId,
    };

const _$ConflictKindEnumMap = {
  ConflictKind.timeOverlap: 'time_overlap',
  ConflictKind.existingOverlap: 'existing_overlap',
  ConflictKind.noBreak: 'no_break',
  ConflictKind.categoryMonotony: 'category_monotony',
  ConflictKind.outsideAwake: 'outside_awake',
};

const _$ConflictSeverityEnumMap = {
  ConflictSeverity.error: 'error',
  ConflictSeverity.warning: 'warning',
};
