# 03 — ScheduleConflictDetector

Status: done
의존성: 01
관련 ADR: 0002
완료: 2026-05-03 — conflict_report.dart (freezed) + schedule_conflict_detector.dart, 5종 ConflictKind 18/18 PASS, 0 warning.

## 목적

생성된 items 와 기존 DB schedules 간 5종 충돌을 감지. 호출 지점은 (a) 생성 직후 자동 (b) 적용 직전 재검사. 순수 Dart.

## 변경/신규 파일

- `lib/features/schedule/domain/schedule_conflict_detector.dart` (신규)
- `test/features/schedule/domain/schedule_conflict_detector_test.dart` (신규)

## 설계 메모

```dart
enum ConflictKind {
  timeOverlap,         // 동일 day 두 신규 items 겹침
  existingOverlap,     // 신규 vs 기존 DB schedules 겹침
  noBreak,             // 인접 items gap < kMinBreakMin (work→work 30)
  categoryMonotony,    // 동일 day 동일 category N회 연속
  outsideAwake,        // wake 이전 / sleep 이후
}

enum ConflictSeverity { error, warning }

@freezed
sealed class ConflictReport with _$ConflictReport {
  const factory ConflictReport({
    required ConflictKind kind,
    required List<int> indices,        // proposed items 인덱스
    int? existingId,                   // existingOverlap 시 DB row id
    required ConflictSeverity severity,
    required String message,
  }) = _ConflictReport;
}

class ScheduleConflictDetector {
  const ScheduleConflictDetector();
  
  List<ConflictReport> detect({
    required List<GeneratedScheduleItem> proposed,
    required List<DateTime Function(DateTime)> /* unused */,
    required Iterable<({int id, DateTime? start, DateTime? end})> existingThisWeek,
    required AwakeWindow awake,
    required DateTime weekStart,
  });
}
```

### Severity 정책 (ADR 0002 후보)

- `timeOverlap` → error (적용 차단 권장 + UI 빨강)
- `existingOverlap` → error (적용 차단 권장 + UI 빨강 + 기존 row 하이라이트)
- `noBreak` → warning (UI 노랑, 적용 허용)
- `categoryMonotony` → warning
- `outsideAwake` → warning

### 알고리즘

- O(n²) 단순 검사 (n ≤ 18 이므로 충분)
- 인접성: 정렬 후 i, i+1 페어
- noBreak: same day, gap = next.startMinute - cur.endMinute < threshold
- categoryMonotony: 정렬 후 윈도우 N=3 sliding
- existingOverlap: existing 의 (start, end) 가 모두 non-null + 같은 ISO week 만 비교

## DoD

- [ ] 5종 ConflictKind 모두 검출 가능
- [ ] 양/음성 케이스 단위 테스트 ≥ 15 (각 kind 양/음성 + 빈 입력 + 동일 시각 경계 + 자정 넘김)
- [ ] severity 정책 코드/주석에 명시 + ADR 0002 참조
- [ ] freezed `ConflictReport` build_runner 통과
- [ ] `flutter analyze` 0 warning

## 검증

- TDD
- 회귀 0건
