// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routinemon/features/schedule/domain/schedule_category.dart';

part 'auto_schedule_models.freezed.dart';
part 'auto_schedule_models.g.dart';

/// JSON source of an auto-schedule result.
enum AutoScheduleSource {
  @JsonValue('llm')
  llm,
  @JsonValue('preset')
  preset,
}

/// Request body sent to n8n `routinemon-auto-schedule` webhook.
@freezed
sealed class AutoScheduleRequest with _$AutoScheduleRequest {
  const factory AutoScheduleRequest({
    required String text,
    @JsonKey(name: 'user_locale') required String userLocale,
  }) = _AutoScheduleRequest;

  factory AutoScheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$AutoScheduleRequestFromJson(json);
}

/// Structured schedule inferred by the LLM (or preset fallback).
@freezed
sealed class AutoScheduleResponse with _$AutoScheduleResponse {
  const AutoScheduleResponse._();

  const factory AutoScheduleResponse({
    required String title,
    @JsonKey(name: 'start_time') required DateTime? startTime,
    @JsonKey(name: 'end_time') required DateTime? endTime,
    @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
    required ScheduleCategory category,
    required List<String> tags,
    required double confidence,
    required AutoScheduleSource source,
  }) = _AutoScheduleResponse;

  /// True when the caller should prompt the user before committing.
  bool get needsUserConfirmation => confidence < 0.5;

  factory AutoScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$AutoScheduleResponseFromJson(json);
}

ScheduleCategory _categoryFromJson(String value) =>
    ScheduleCategory.fromString(value);

String _categoryToJson(ScheduleCategory c) => c.name;
