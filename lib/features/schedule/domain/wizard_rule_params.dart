// Pure Dart. Path A (rule-based) 결정론 알고리즘의 튜닝 파라미터 단일 출처.
// 관련 ADR: 0001 (rule-based default), 0002 (conflict detection policy).
// 1주차 실측 후 재조정 가능 — Open Decision §1, §2 (`.scratch/weekly-wizard-v2/PRD.md`).

/// Deep focus block 길이 (분).
const int kFocusBlockMinDeep = 90;

/// Shallow focus block 길이 (분).
const int kFocusBlockMinShallow = 45;

/// 식사 길이 (분).
const int kMealDurationBreakfast = 30;
const int kMealDurationLunch = 45;
const int kMealDurationDinner = 60;

/// 운동 빈도별 1회 길이 (분).
const int kExerciseDurationLight = 30;
const int kExerciseDurationModerate = 45;
const int kExerciseDurationDaily = 60;

/// 취미 길이 (분).
const int kHobbyDurationWeekday = 90;
const int kHobbyDurationWeekend = 120;

/// 충돌 감지 — 인접 슬롯 최소 휴식 (ADR 0002).
const int kMinBreakMin = 15;
const int kMinBreakWorkToWork = 30;

/// 충돌 감지 — 동일 카테고리 연속 임계 (ADR 0002).
const int kCategoryMonotonyN = 3;

/// PastWeekContext 보정 — 이행률 임계 + 부하 축소 비율.
const double kPastWeekLowThreshold = 0.5;
const double kPastWeekReductionRatio = 0.7;
