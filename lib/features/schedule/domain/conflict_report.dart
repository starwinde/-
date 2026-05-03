// ignore_for_file: invalid_annotation_target

// Pure Dart. Path A 출력에 첨부되는 충돌 리포트. ADR 0002 (severity 정책 + 자동 호출 지점).
// freezed_annotation 은 dart code-gen 만 — framework 아님 (rules.md §3.3).
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conflict_report.freezed.dart';
part 'conflict_report.g.dart';

enum ConflictKind {
  /// 동일 day 내 두 신규 items 시간 겹침. severity=error.
  @JsonValue('time_overlap')
  timeOverlap,

  /// 신규 items 와 기존 DB schedules 겹침. severity=error.
  @JsonValue('existing_overlap')
  existingOverlap,

  /// 인접 items gap < kMinBreakMin (work→work 30). severity=warning.
  @JsonValue('no_break')
  noBreak,

  /// 동일 day 동일 category N(=3)회 연속. severity=warning.
  @JsonValue('category_monotony')
  categoryMonotony,

  /// wake 이전 / sleep 이후 배치. severity=warning.
  @JsonValue('outside_awake')
  outsideAwake,
}

enum ConflictSeverity {
  @JsonValue('error') error,
  @JsonValue('warning') warning,
}

@freezed
sealed class ConflictReport with _$ConflictReport {
  const factory ConflictReport({
    required ConflictKind kind,
    required List<int> indices,
    required ConflictSeverity severity,
    required String message,
    @JsonKey(name: 'existing_id') int? existingId,
  }) = _ConflictReport;

  factory ConflictReport.fromJson(Map<String, dynamic> json) =>
      _$ConflictReportFromJson(json);
}
