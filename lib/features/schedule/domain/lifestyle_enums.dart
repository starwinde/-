// Pure Dart, framework imports 금지 (rules.md §3.3).
// 라이프스타일 응답 enum. wizard_models.dart 가 re-export 해 기존 import 경로 호환 유지.
import 'package:json_annotation/json_annotation.dart';

enum WakeTime {
  @JsonValue('early_5_7') early57,
  @JsonValue('morning_7_9') morning79,
  @JsonValue('late_9_11') late911,
  @JsonValue('variable') variable,
}

enum SleepTime {
  @JsonValue('early_21_23') early2123,
  @JsonValue('midnight_23_1') midnight231,
  @JsonValue('late_1_3') late13,
  @JsonValue('variable') variable,
}

enum Chronotype {
  @JsonValue('morning') morning,
  @JsonValue('middle') middle,
  @JsonValue('evening') evening,
}
