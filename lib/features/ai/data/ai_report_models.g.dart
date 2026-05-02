// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiReportInputData _$AiReportInputDataFromJson(Map<String, dynamic> json) =>
    _AiReportInputData(
      focusSessions: (json['focus_sessions'] as num).toInt(),
      avgFocusRatio: (json['avg_focus_ratio'] as num).toDouble(),
      plannedMinutes: (json['planned_minutes'] as num?)?.toInt() ?? 0,
      actualFocusMinutes: (json['actual_focus_minutes'] as num?)?.toInt() ?? 0,
      sessionsByGrade:
          (json['sessions_by_grade'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      todosTotal: (json['todos_total'] as num?)?.toInt() ?? 0,
      todosCompleted: (json['todos_completed'] as num?)?.toInt() ?? 0,
      todosCompletedOnDueDay:
          (json['todos_completed_on_due_day'] as num?)?.toInt() ?? 0,
      nonTodoCompleted: (json['non_todo_completed'] as num?)?.toInt() ?? 0,
      tasksCompleted: (json['tasks_completed'] as num).toInt(),
      tasksTotal: (json['tasks_total'] as num).toInt(),
      schedulesCreated: (json['schedules_created'] as num?)?.toInt() ?? 0,
      schedulesTotalMinutes:
          (json['schedules_total_minutes'] as num?)?.toInt() ?? 0,
      categoryDistribution:
          (json['category_distribution'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      streakDays: (json['streak_days'] as num).toInt(),
    );

Map<String, dynamic> _$AiReportInputDataToJson(_AiReportInputData instance) =>
    <String, dynamic>{
      'focus_sessions': instance.focusSessions,
      'avg_focus_ratio': instance.avgFocusRatio,
      'planned_minutes': instance.plannedMinutes,
      'actual_focus_minutes': instance.actualFocusMinutes,
      'sessions_by_grade': instance.sessionsByGrade,
      'todos_total': instance.todosTotal,
      'todos_completed': instance.todosCompleted,
      'todos_completed_on_due_day': instance.todosCompletedOnDueDay,
      'non_todo_completed': instance.nonTodoCompleted,
      'tasks_completed': instance.tasksCompleted,
      'tasks_total': instance.tasksTotal,
      'schedules_created': instance.schedulesCreated,
      'schedules_total_minutes': instance.schedulesTotalMinutes,
      'category_distribution': instance.categoryDistribution,
      'streak_days': instance.streakDays,
    };

_AiReportRequest _$AiReportRequestFromJson(Map<String, dynamic> json) =>
    _AiReportRequest(
      userId: json['user_id'] as String,
      period: $enumDecode(_$ReportPeriodEnumMap, json['period']),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      data: AiReportInputData.fromJson(json['data'] as Map<String, dynamic>),
      userLocale: json['user_locale'] as String,
    );

Map<String, dynamic> _$AiReportRequestToJson(_AiReportRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'period': _$ReportPeriodEnumMap[instance.period]!,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'data': instance.data.toJson(),
      'user_locale': instance.userLocale,
    };

const _$ReportPeriodEnumMap = {
  ReportPeriod.weekly: 'weekly',
  ReportPeriod.monthly: 'monthly',
};

_AiReportResponse _$AiReportResponseFromJson(Map<String, dynamic> json) =>
    _AiReportResponse(
      summary: json['summary'] as String,
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      encouragement: json['encouragement'] as String,
      source: $enumDecode(_$AiReportSourceEnumMap, json['source']),
    );

Map<String, dynamic> _$AiReportResponseToJson(_AiReportResponse instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'insights': instance.insights,
      'suggestions': instance.suggestions,
      'encouragement': instance.encouragement,
      'source': _$AiReportSourceEnumMap[instance.source]!,
    };

const _$AiReportSourceEnumMap = {
  AiReportSource.llm: 'llm',
  AiReportSource.preset: 'preset',
};
