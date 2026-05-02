// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PdfReportMeta _$PdfReportMetaFromJson(Map<String, dynamic> json) =>
    _PdfReportMeta(
      petName: json['pet_name'] as String?,
      userName: json['user_name'] as String?,
      periodLabel: json['period_label'] as String?,
    );

Map<String, dynamic> _$PdfReportMetaToJson(_PdfReportMeta instance) =>
    <String, dynamic>{
      'pet_name': instance.petName,
      'user_name': instance.userName,
      'period_label': instance.periodLabel,
    };

_PdfReportRequest _$PdfReportRequestFromJson(Map<String, dynamic> json) =>
    _PdfReportRequest(
      userId: json['user_id'] as String,
      period: $enumDecode(_$ReportPeriodEnumMap, json['period']),
      report: AiReportResponse.fromJson(json['report'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : PdfReportMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PdfReportRequestToJson(_PdfReportRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'period': _$ReportPeriodEnumMap[instance.period]!,
      'report': instance.report.toJson(),
      'meta': instance.meta?.toJson(),
    };

const _$ReportPeriodEnumMap = {
  ReportPeriod.weekly: 'weekly',
  ReportPeriod.monthly: 'monthly',
};
