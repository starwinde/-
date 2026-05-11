# Occupation-Aware Wizard PR1 — Telemetry + n8n Branching

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the data path that lets LLM enhance differentiate weekly schedules by occupation (worker/student/freelancer/homemaker/retired/other) without changing wizard UX. Adds optional `OccupationProfile` payload + n8n prompt branching + step-level analytics interface. Preserves `WizardAnswers` 15-field canonical so the n8n webhook contract stays intact.

**Architecture:** Extend existing `WizardAnswers` (freezed sealed class) with optional `OccupationProfile` field carrying `effectiveStatus` + `askedFields` (default-fill marker) + `studyMode`/`shiftPattern` sub-modes. n8n system prompt reads `occupation_profile` and emits status-specific invariants. Step-level wizard analytics defined as abstract `WizardAnalyticsService` with NoOp implementation today (PostHog/Firebase wiring lands in Issue 08). No UI change in PR1. Behind an upcoming PR2 (RuleSet + 7-step branched UI), gated on telemetry data showing actual dropoff.

**Tech Stack:** Flutter 3.x, Dart 3, Riverpod (`@riverpod` codegen), Freezed (`@freezed sealed class`), JsonSerializable, drift (DB, untouched here), n8n workflow JSON (`routinemon-weekly-schedule-wizard.json`), flutter_test.

---

## File Structure

**Modify:**
- `lib/features/schedule/domain/lifestyle_enums.dart` — add `StudyMode`, `ShiftPattern` enums
- `lib/features/schedule/data/wizard_models.dart` — add `OccupationProfile` freezed sealed class + `WizardAnswers.occupationProfile?` field
- `lib/features/schedule/application/wizard_state.dart` — `toAnswers()` populates `occupationProfile` with `effectiveStatus` + `askedFields`
- `lib/features/schedule/presentation/wizard_page.dart` — wire analytics events on `onPageChanged` / next / back / dispose
- `n8n/workflows/routinemon-weekly-schedule-wizard.json` — system prompt `[OCCUPATION CONTEXT]` block + status invariants
- `docs/analytics_events.md` — append 4 step-level events spec

**Create:**
- `lib/features/schedule/application/wizard_analytics_service.dart` — abstract `WizardAnalyticsService` + `NoOpWizardAnalyticsService` + `wizardAnalyticsServiceProvider`
- `test/features/schedule/data/wizard_models_backcompat_test.dart` — pre-v3 JSON decodes with `occupationProfile=null`
- `test/features/schedule/data/wizard_webhook_payload_snapshot_test.dart` — toJson() for each LifestyleStatus emits expected payload
- `test/features/schedule/application/wizard_analytics_service_test.dart` — NoOp records events for assertion
- `test/features/schedule/presentation/wizard_analytics_test.dart` — UI hooks fire the right events with right properties

Each file has one responsibility. Tests live next to the code they test under `test/features/schedule/<layer>/`.

---

### Task 1: Add StudyMode + ShiftPattern enums

**Files:**
- Modify: `lib/features/schedule/domain/lifestyle_enums.dart`

- [ ] **Step 1: Append the enums to the existing file**

Open `lib/features/schedule/domain/lifestyle_enums.dart`. After the existing `Chronotype` enum (around line 23), append:

```dart
enum StudyMode {
  @JsonValue('regular') regular,
  @JsonValue('exam_period') examPeriod,
  @JsonValue('vacation') vacation,
}

enum ShiftPattern {
  @JsonValue('day_shift') dayShift,
  @JsonValue('night_shift') nightShift,
  @JsonValue('rotating') rotating,
}
```

- [ ] **Step 2: Run analyze to confirm no syntax error**

Run: `flutter analyze lib/features/schedule/domain/lifestyle_enums.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/schedule/domain/lifestyle_enums.dart
git commit -m "feat(wizard): add StudyMode + ShiftPattern enums for occupation profile

Sub-mode signals used by n8n LLM enhance prompt branching to keep
homemaker/retired schedules structurally distinct from worker/student.
Pure additive; no existing call sites change."
```

---

### Task 2: Define OccupationProfile freezed model

**Files:**
- Modify: `lib/features/schedule/data/wizard_models.dart`
- Test: `test/features/schedule/data/wizard_models_backcompat_test.dart` (created later in Task 6)

- [ ] **Step 1: Add OccupationProfile freezed class**

Open `lib/features/schedule/data/wizard_models.dart`. Above the existing `WizardAnswers` declaration (around line 114), insert:

```dart
@freezed
sealed class OccupationProfile with _$OccupationProfile {
  const factory OccupationProfile({
    /// Mirrors `WizardAnswers.status` so the n8n prompt has a single
    /// authoritative occupation signal. Always present.
    @JsonKey(name: 'effective_status') required LifestyleStatus effectiveStatus,
    /// Snake_case names of every field the user actually answered in the
    /// wizard. n8n prompt uses this to skip default-filled fields.
    @JsonKey(name: 'asked_fields') @Default(<String>[]) List<String> askedFields,
    /// Student-only sub-mode. Null for non-students or when not asked.
    @JsonKey(name: 'study_mode') StudyMode? studyMode,
    /// Worker-only sub-mode. Null for non-workers or when not asked.
    @JsonKey(name: 'shift_pattern') ShiftPattern? shiftPattern,
  }) = _OccupationProfile;

  factory OccupationProfile.fromJson(Map<String, dynamic> json) =>
      _$OccupationProfileFromJson(json);
}
```

- [ ] **Step 2: Add the optional field to WizardAnswers**

In the same file, modify the `WizardAnswers` factory (around line 116). Inside the parameter list, just before the closing `}) = _WizardAnswers;`, add:

```dart
    @JsonKey(name: 'occupation_profile') OccupationProfile? occupationProfile,
```

The full factory should now look like:

```dart
  const factory WizardAnswers({
    required LifestyleStatus status,
    @JsonKey(name: 'wake_time') required WakeTime wakeTime,
    @JsonKey(name: 'sleep_time') required SleepTime sleepTime,
    required Chronotype chronotype,
    @JsonKey(name: 'work_days') required WorkDays workDays,
    @JsonKey(name: 'work_hours') required WorkHours workHours,
    @JsonKey(name: 'commute_time') CommuteTime? commuteTime,
    @JsonKey(name: 'meal_pattern') required MealPattern mealPattern,
    @JsonKey(name: 'focus_time') required FocusTimeWindow focusTime,
    required ExerciseFrequency exercise,
    @JsonKey(name: 'exercise_preferred_time')
    ExercisePreferredTime? exercisePreferredTime,
    required HobbyPreference hobby,
    @JsonKey(name: 'goal_focus') required GoalFocus goalFocus,
    @JsonKey(name: 'free_time') required FreeTimeMin freeTime,
    @JsonKey(name: 'fixed_schedules') String? fixedSchedules,
    @JsonKey(name: 'user_locale') @Default('ko') String userLocale,
    @JsonKey(name: 'past_week_context') PastWeekContext? pastWeekContext,
    @JsonKey(name: 'occupation_profile') OccupationProfile? occupationProfile,
  }) = _WizardAnswers;
```

- [ ] **Step 3: Run build_runner to regenerate freezed/json**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Succeeds; `wizard_models.freezed.dart` and `wizard_models.g.dart` are updated.

- [ ] **Step 4: Run analyze on the file**

Run: `flutter analyze lib/features/schedule/data/`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/schedule/data/wizard_models.dart \
        lib/features/schedule/data/wizard_models.freezed.dart \
        lib/features/schedule/data/wizard_models.g.dart
git commit -m "feat(wizard): add OccupationProfile + WizardAnswers.occupationProfile

OccupationProfile carries effectiveStatus + askedFields + study_mode +
shift_pattern. Optional/nullable on WizardAnswers — pre-v3 stored payloads
decode unchanged. Webhook contract is additive; n8n can ignore the new field
until the prompt branching ships in Task 11."
```

---

### Task 3: Backward-compat decode test (red)

**Files:**
- Create: `test/features/schedule/data/wizard_models_backcompat_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/schedule/data/wizard_models_backcompat_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

void main() {
  group('WizardAnswers.fromJson backward compatibility', () {
    test('decodes pre-v3 payload (no occupation_profile) with field=null',
        () {
      // Snapshot of a v2 wizard payload (15 fields, no occupation_profile).
      final preV3Json = <String, dynamic>{
        'status': 'worker',
        'wake_time': 'morning_7_9',
        'sleep_time': 'midnight_23_1',
        'chronotype': 'middle',
        'work_days': 'd5',
        'work_hours': 'nine_to_six',
        'commute_time': 'about_1h',
        'meal_pattern': 'regular_3',
        'focus_time': 'morning',
        'exercise': 'moderate',
        'exercise_preferred_time': 'evening',
        'hobby': 'weekdayEvening',
        'goal_focus': 'work_study',
        'free_time': 'twoHours',
        'fixed_schedules': null,
        'user_locale': 'ko',
        'past_week_context': null,
      };

      final answers = WizardAnswers.fromJson(preV3Json);

      expect(answers.status, LifestyleStatus.worker);
      expect(answers.workDays, WorkDays.d5);
      expect(answers.occupationProfile, isNull);
    });

    test('decodes v3 payload with full occupation_profile', () {
      final v3Json = <String, dynamic>{
        'status': 'student',
        'wake_time': 'morning_7_9',
        'sleep_time': 'midnight_23_1',
        'chronotype': 'middle',
        'work_days': 'd5',
        'work_hours': 'nine_to_six',
        'meal_pattern': 'regular_3',
        'focus_time': 'morning',
        'exercise': 'light',
        'hobby': 'weekend',
        'goal_focus': 'work_study',
        'free_time': 'twoHours',
        'occupation_profile': <String, dynamic>{
          'effective_status': 'student',
          'asked_fields': <String>['status', 'wake_time', 'sleep_time'],
          'study_mode': 'exam_period',
          'shift_pattern': null,
        },
      };

      final answers = WizardAnswers.fromJson(v3Json);

      expect(answers.occupationProfile, isNotNull);
      expect(answers.occupationProfile!.effectiveStatus,
          LifestyleStatus.student);
      expect(answers.occupationProfile!.studyMode, StudyMode.examPeriod);
      expect(answers.occupationProfile!.shiftPattern, isNull);
      expect(answers.occupationProfile!.askedFields,
          ['status', 'wake_time', 'sleep_time']);
    });

    test('decodes v3 payload with partial occupation_profile (no sub-mode)',
        () {
      final v3Partial = <String, dynamic>{
        'status': 'homemaker',
        'wake_time': 'morning_7_9',
        'sleep_time': 'midnight_23_1',
        'chronotype': 'middle',
        'work_days': 'irregular',
        'work_hours': 'other',
        'meal_pattern': 'regular_3',
        'focus_time': 'morning',
        'exercise': 'light',
        'hobby': 'weekdayEvening',
        'goal_focus': 'rest',
        'free_time': 'twoHours',
        'occupation_profile': <String, dynamic>{
          'effective_status': 'homemaker',
        },
      };

      final answers = WizardAnswers.fromJson(v3Partial);

      expect(answers.occupationProfile!.effectiveStatus,
          LifestyleStatus.homemaker);
      expect(answers.occupationProfile!.askedFields, isEmpty);
      expect(answers.occupationProfile!.studyMode, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it passes**

Run: `flutter test test/features/schedule/data/wizard_models_backcompat_test.dart`
Expected: 3 tests pass (Task 2 already added the field; this test validates correctness).

If it fails, the issue is in Task 2's `OccupationProfile` definition — fix and re-run.

- [ ] **Step 3: Commit**

```bash
git add test/features/schedule/data/wizard_models_backcompat_test.dart
git commit -m "test(wizard): backward-compat decode for OccupationProfile

Asserts pre-v3 payload (15 fields, no occupation_profile) decodes with
occupationProfile=null, plus full and partial v3 payloads."
```

---

### Task 4: Update WizardState.toAnswers() to populate occupationProfile

**Files:**
- Modify: `lib/features/schedule/application/wizard_state.dart:131-168`

- [ ] **Step 1: Add the askedFields constant**

Open `lib/features/schedule/application/wizard_state.dart`. Above the `WizardState` class declaration (around line 105), insert:

```dart
/// Snake_case wizard answer keys captured by the v2 (current) 15-step wizard.
/// In PR2 (occupation-branched UI), this list will become per-status so
/// homemaker/retired skip work_days/work_hours.
const List<String> _kV2AskedFields = <String>[
  'status',
  'wake_time',
  'sleep_time',
  'chronotype',
  'work_days',
  'work_hours',
  'commute_time',
  'meal_pattern',
  'focus_time',
  'exercise',
  'exercise_preferred_time',
  'hobby',
  'goal_focus',
  'free_time',
  'fixed_schedules',
];
```

- [ ] **Step 2: Modify toAnswers() to attach occupationProfile**

In the same file, find the `toAnswers()` method (line 134-168). Replace the final `return WizardAnswers(...)` block with:

```dart
    final fixed = s.fixedSchedules;
    return WizardAnswers(
      status: s.status!,
      wakeTime: s.wakeTime!,
      sleepTime: s.sleepTime!,
      chronotype: s.chronotype!,
      workDays: s.workDays!,
      workHours: s.workHours!,
      commuteTime: s.commuteTime,
      mealPattern: s.mealPattern!,
      focusTime: s.focusTime!,
      exercise: s.exercise!,
      exercisePreferredTime: s.exercisePreferredTime,
      hobby: s.hobby!,
      goalFocus: s.goalFocus!,
      freeTime: s.freeTime!,
      fixedSchedules: (fixed == null || fixed.isEmpty) ? null : fixed,
      occupationProfile: OccupationProfile(
        effectiveStatus: s.status!,
        askedFields: _kV2AskedFields,
        // study_mode + shift_pattern arrive in PR2 (occupation-branched UI).
      ),
    );
```

- [ ] **Step 3: Run analyze**

Run: `flutter analyze lib/features/schedule/application/wizard_state.dart`
Expected: `No issues found!`

- [ ] **Step 4: Run existing wizard tests to confirm no regression**

Run: `flutter test test/features/schedule/`
Expected: All existing tests pass (the new field is additive; toAnswers signature unchanged).

- [ ] **Step 5: Commit**

```bash
git add lib/features/schedule/application/wizard_state.dart
git commit -m "feat(wizard): WizardState.toAnswers populates occupationProfile

Every wizard completion now includes effectiveStatus + askedFields. n8n
prompt (Task 11) uses askedFields to skip default-filled fields for
homemaker/retired. study_mode/shift_pattern are PR2 territory."
```

---

### Task 5: Webhook payload snapshot test

**Files:**
- Create: `test/features/schedule/data/wizard_webhook_payload_snapshot_test.dart`

- [ ] **Step 1: Write the snapshot test**

Create `test/features/schedule/data/wizard_webhook_payload_snapshot_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';

void main() {
  group('WizardAnswers.toJson webhook snapshot', () {
    WizardAnswers buildAnswers(LifestyleStatus status) => WizardAnswers(
          status: status,
          wakeTime: WakeTime.morning79,
          sleepTime: SleepTime.midnight231,
          chronotype: Chronotype.middle,
          workDays: WorkDays.d5,
          workHours: WorkHours.nineToSix,
          commuteTime: CommuteTime.about1h,
          mealPattern: MealPattern.regular3,
          focusTime: FocusTimeWindow.morning,
          exercise: ExerciseFrequency.moderate,
          exercisePreferredTime: ExercisePreferredTime.evening,
          hobby: HobbyPreference.weekdayEvening,
          goalFocus: GoalFocus.workStudy,
          freeTime: FreeTimeMin.twoHours,
          occupationProfile: OccupationProfile(
            effectiveStatus: status,
            askedFields: const <String>['status', 'wake_time'],
          ),
        );

    test('toJson includes occupation_profile.effective_status for every status',
        () {
      for (final status in LifestyleStatus.values) {
        final json = buildAnswers(status).toJson();
        expect(json.containsKey('occupation_profile'), isTrue,
            reason: 'status=$status missing occupation_profile');
        final profile = json['occupation_profile'] as Map<String, dynamic>;
        expect(profile['effective_status'], status.name.replaceAllMapped(
          RegExp(r'(?<=[a-z])([A-Z])'),
          (m) => '_${m[1]!.toLowerCase()}',
        ).toLowerCase(),
            reason: 'status=$status has wrong effective_status');
        expect(profile['asked_fields'], <String>['status', 'wake_time']);
      }
    });

    test('toJson keeps the legacy 15 fields intact', () {
      final json = buildAnswers(LifestyleStatus.worker).toJson();
      expect(json['status'], 'worker');
      expect(json['wake_time'], 'morning_7_9');
      expect(json['work_days'], 'd5');
      expect(json['work_hours'], 'nine_to_six');
      expect(json['focus_time'], 'morning');
      expect(json['goal_focus'], 'work_study');
      expect(json['free_time'], 'twoHours');
    });

    test('toJson omits null occupation_profile when not set', () {
      final answers = WizardAnswers(
        status: LifestyleStatus.worker,
        wakeTime: WakeTime.morning79,
        sleepTime: SleepTime.midnight231,
        chronotype: Chronotype.middle,
        workDays: WorkDays.d5,
        workHours: WorkHours.nineToSix,
        mealPattern: MealPattern.regular3,
        focusTime: FocusTimeWindow.morning,
        exercise: ExerciseFrequency.moderate,
        hobby: HobbyPreference.weekdayEvening,
        goalFocus: GoalFocus.workStudy,
        freeTime: FreeTimeMin.twoHours,
        // occupationProfile intentionally null
      );
      final json = answers.toJson();
      expect(json['occupation_profile'], isNull);
    });
  });
}
```

- [ ] **Step 2: Run test**

Run: `flutter test test/features/schedule/data/wizard_webhook_payload_snapshot_test.dart`
Expected: All 3 tests pass.

The first test maps Dart camelCase enum names to the snake_case `@JsonValue` strings via regex. If a status uses a non-standard JsonValue (e.g., `@JsonValue('homemaker')` for `homemaker`), the regex transform produces the same string and the assertion holds. If you add a status whose enum case differs from its JsonValue, fix the test to look up the value via `LifestyleStatus.values.firstWhere(...)` or hardcode the map.

- [ ] **Step 3: Commit**

```bash
git add test/features/schedule/data/wizard_webhook_payload_snapshot_test.dart
git commit -m "test(wizard): webhook payload snapshot for OccupationProfile

Verifies every LifestyleStatus produces a toJson() with effective_status
+ asked_fields, legacy 15 fields stay intact, null occupationProfile
roundtrips as null in JSON."
```

---

### Task 6: WizardAnalyticsService abstract + NoOp implementation

**Files:**
- Create: `lib/features/schedule/application/wizard_analytics_service.dart`
- Test: `test/features/schedule/application/wizard_analytics_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/schedule/application/wizard_analytics_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/application/wizard_analytics_service.dart';

void main() {
  group('NoOpWizardAnalyticsService (test recording mode)', () {
    test('records stepViewed events for assertion', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.stepViewed(stepId: 'status', stepIndex: 0, totalSteps: 15,
          status: null);
      svc.stepViewed(stepId: 'wake_time', stepIndex: 1, totalSteps: 15,
          status: 'worker');
      expect(svc.recorded.length, 2);
      expect(svc.recorded[0]['event'], 'wizard_step_viewed');
      expect(svc.recorded[0]['step_id'], 'status');
      expect(svc.recorded[0]['status'], isNull);
      expect(svc.recorded[1]['status'], 'worker');
    });

    test('records stepCompleted with time_to_complete_ms', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.stepCompleted(
          stepId: 'wake_time', stepIndex: 1, timeToCompleteMs: 4200);
      expect(svc.recorded.single['event'], 'wizard_step_completed');
      expect(svc.recorded.single['time_to_complete_ms'], 4200);
    });

    test('records stepBack with from/to step ids', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.stepBack(fromStepId: 'sleep_time', toStepId: 'wake_time');
      expect(svc.recorded.single['event'], 'wizard_step_back');
      expect(svc.recorded.single['from_step_id'], 'sleep_time');
      expect(svc.recorded.single['to_step_id'], 'wake_time');
    });

    test('records abandoned with last step', () {
      final svc = NoOpWizardAnalyticsService(record: true);
      svc.abandoned(lastStepId: 'meal_pattern', stepIndex: 7, totalSteps: 15);
      expect(svc.recorded.single['event'], 'wizard_abandoned');
      expect(svc.recorded.single['last_step_id'], 'meal_pattern');
      expect(svc.recorded.single['step_index'], 7);
    });

    test('record=false swallows events (production mode)', () {
      final svc = NoOpWizardAnalyticsService(record: false);
      svc.stepViewed(stepId: 'status', stepIndex: 0, totalSteps: 15,
          status: null);
      expect(svc.recorded, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/schedule/application/wizard_analytics_service_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:routinemon/features/schedule/application/wizard_analytics_service.dart'`

- [ ] **Step 3: Write the implementation**

Create `lib/features/schedule/application/wizard_analytics_service.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wizard_analytics_service.g.dart';

/// Step-level wizard analytics interface.
///
/// PR1 ships only the data path. Real PostHog/Firebase wiring lands in
/// `.scratch/weekly-wizard-v2/issues/08-analytics-and-adr.md` (deferred per
/// that issue's "analytics service 미구현" note).
///
/// Event spec: see `docs/analytics_events.md` §wizard_step_*.
abstract class WizardAnalyticsService {
  void stepViewed({
    required String stepId,
    required int stepIndex,
    required int totalSteps,
    required String? status,
  });

  void stepCompleted({
    required String stepId,
    required int stepIndex,
    required int timeToCompleteMs,
  });

  void stepBack({
    required String fromStepId,
    required String toStepId,
  });

  void abandoned({
    required String lastStepId,
    required int stepIndex,
    required int totalSteps,
  });
}

/// Default implementation. In production it is silent. In tests, pass
/// `record: true` to capture events for assertion.
class NoOpWizardAnalyticsService implements WizardAnalyticsService {
  NoOpWizardAnalyticsService({this.record = false});

  final bool record;
  final List<Map<String, Object?>> recorded = <Map<String, Object?>>[];

  void _capture(Map<String, Object?> event) {
    if (record) {
      recorded.add(event);
    } else if (kDebugMode) {
      debugPrint('[wizard-analytics] ${event['event']}: $event');
    }
  }

  @override
  void stepViewed({
    required String stepId,
    required int stepIndex,
    required int totalSteps,
    required String? status,
  }) {
    _capture({
      'event': 'wizard_step_viewed',
      'step_id': stepId,
      'step_index': stepIndex,
      'total_steps': totalSteps,
      'status': status,
    });
  }

  @override
  void stepCompleted({
    required String stepId,
    required int stepIndex,
    required int timeToCompleteMs,
  }) {
    _capture({
      'event': 'wizard_step_completed',
      'step_id': stepId,
      'step_index': stepIndex,
      'time_to_complete_ms': timeToCompleteMs,
    });
  }

  @override
  void stepBack({
    required String fromStepId,
    required String toStepId,
  }) {
    _capture({
      'event': 'wizard_step_back',
      'from_step_id': fromStepId,
      'to_step_id': toStepId,
    });
  }

  @override
  void abandoned({
    required String lastStepId,
    required int stepIndex,
    required int totalSteps,
  }) {
    _capture({
      'event': 'wizard_abandoned',
      'last_step_id': lastStepId,
      'step_index': stepIndex,
      'total_steps': totalSteps,
    });
  }
}

/// Riverpod provider — overridden in tests with a recording NoOp.
@riverpod
WizardAnalyticsService wizardAnalyticsService(Ref ref) =>
    NoOpWizardAnalyticsService();
```

- [ ] **Step 4: Run build_runner for the @riverpod codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `wizard_analytics_service.g.dart`.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/schedule/application/wizard_analytics_service_test.dart`
Expected: All 5 tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/schedule/application/wizard_analytics_service.dart \
        lib/features/schedule/application/wizard_analytics_service.g.dart \
        test/features/schedule/application/wizard_analytics_service_test.dart
git commit -m "feat(wizard): WizardAnalyticsService interface + NoOp impl

Defines the 4 step-level events (viewed/completed/back/abandoned). NoOp
silently swallows in prod; record=true captures for tests. Real PostHog/
Firebase wiring lands in Issue 08."
```

---

### Task 7: Wire analytics into wizard_page.dart

**Files:**
- Modify: `lib/features/schedule/presentation/wizard_page.dart`
- Test: `test/features/schedule/presentation/wizard_analytics_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/features/schedule/presentation/wizard_analytics_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:routinemon/features/schedule/application/wizard_analytics_service.dart';
import 'package:routinemon/features/schedule/presentation/wizard_page.dart';

void main() {
  late NoOpWizardAnalyticsService recorder;

  setUp(() {
    recorder = NoOpWizardAnalyticsService(record: true);
  });

  Widget buildHarness() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const WizardPage()),
      GoRoute(path: '/schedule/wizard/preview',
          builder: (_, __) => const SizedBox.shrink()),
    ]);
    return ProviderScope(
      overrides: [
        wizardAnalyticsServiceProvider.overrideWith((_) => recorder),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('first step view fires wizard_step_viewed for status step',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.pumpAndSettle();

    expect(recorder.recorded, isNotEmpty);
    final first = recorder.recorded.first;
    expect(first['event'], 'wizard_step_viewed');
    expect(first['step_index'], 0);
    expect(first['status'], isNull); // status not selected yet
  });

  testWidgets('selecting status then advancing fires step_completed + step_viewed',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.pumpAndSettle();
    recorder.recorded.clear();

    // Tap '직장인' radio.
    await tester.tap(find.text('직장인'));
    await tester.pumpAndSettle();

    // Tap '다음'.
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    final events = recorder.recorded.map((e) => e['event']).toList();
    expect(events, contains('wizard_step_completed'));
    expect(events, contains('wizard_step_viewed'));
    final completed = recorder.recorded
        .firstWhere((e) => e['event'] == 'wizard_step_completed');
    expect(completed['step_index'], 0);
  });

  testWidgets('disposing wizard before completion fires wizard_abandoned',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.pumpAndSettle();

    // Tear down without completing.
    await tester.pumpWidget(const SizedBox.shrink());

    final abandoned = recorder.recorded
        .where((e) => e['event'] == 'wizard_abandoned')
        .toList();
    expect(abandoned, hasLength(1));
    expect(abandoned.single['step_index'], 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/schedule/presentation/wizard_analytics_test.dart`
Expected: FAIL — analytics events not yet wired (recorder stays empty).

- [ ] **Step 3: Wire the analytics in wizard_page.dart**

Open `lib/features/schedule/presentation/wizard_page.dart`. At the top of the imports (after the existing `wizard_state.dart` import), add:

```dart
import 'package:routinemon/features/schedule/application/wizard_analytics_service.dart';
```

In the `_WizardPageState` class, add three new fields after the existing `int _currentIndex = 0;` line:

```dart
  DateTime _stepEnteredAt = DateTime.now();
  bool _completed = false;
  String _stepIdAt(int index, List<_WizardStep> steps) =>
      steps[index.clamp(0, steps.length - 1)].name;
```

Replace `dispose()` with:

```dart
  @override
  void dispose() {
    if (!_completed) {
      // Best-effort fire-and-forget; provider may be disposed already.
      try {
        ref.read(wizardAnalyticsServiceProvider).abandoned(
              lastStepId: _stepIdAt(
                _currentIndex,
                _visibleSteps(ref.read(wizardStateProvider)),
              ),
              stepIndex: _currentIndex,
              totalSteps:
                  _visibleSteps(ref.read(wizardStateProvider)).length,
            );
      } catch (_) {
        // Provider container torn down — ignore.
      }
    }
    _pageController.dispose();
    _fixedController.dispose();
    super.dispose();
  }
```

Modify `_submit()` to set the `_completed` flag:

```dart
  void _submit() {
    _completed = true;
    ref.read(wizardStateProvider.notifier).setFixed(_fixedController.text);
    context.push('/schedule/wizard/preview');
  }
```

In the `build()` method, find the `PageView.builder(` call. Replace its `onPageChanged:` callback (and add a `WidgetsBinding.instance.addPostFrameCallback` for the very first step's view event, just before `return Scaffold(...)`):

Just before `return Scaffold(`, insert:

```dart
    // Fire wizard_step_viewed for the very first frame on first build.
    if (_currentIndex == 0 && safeIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(wizardAnalyticsServiceProvider).stepViewed(
              stepId: _stepIdAt(0, steps),
              stepIndex: 0,
              totalSteps: steps.length,
              status: draft.status?.name,
            );
        _stepEnteredAt = DateTime.now();
      });
    }
```

Replace the existing `onPageChanged: (i) => setState(() => _currentIndex = i),` line with:

```dart
        onPageChanged: (i) {
          final analytics = ref.read(wizardAnalyticsServiceProvider);
          final prevId = _stepIdAt(_currentIndex, steps);
          final newId = _stepIdAt(i, steps);
          final dwellMs = DateTime.now().difference(_stepEnteredAt).inMilliseconds;
          if (i > _currentIndex) {
            analytics.stepCompleted(
              stepId: prevId,
              stepIndex: _currentIndex,
              timeToCompleteMs: dwellMs,
            );
          } else if (i < _currentIndex) {
            analytics.stepBack(fromStepId: prevId, toStepId: newId);
          }
          analytics.stepViewed(
            stepId: newId,
            stepIndex: i,
            totalSteps: steps.length,
            status: draft.status?.name,
          );
          _stepEnteredAt = DateTime.now();
          setState(() => _currentIndex = i);
        },
```

- [ ] **Step 4: Run analyze**

Run: `flutter analyze lib/features/schedule/presentation/wizard_page.dart`
Expected: `No issues found!`

- [ ] **Step 5: Run the widget test to verify it passes**

Run: `flutter test test/features/schedule/presentation/wizard_analytics_test.dart`
Expected: All 3 tests pass.

If the abandoned-on-dispose test fails because `ref.read` after dispose throws synchronously, the `try/catch` should swallow it; verify the recorder still gets the call by reading the test failure. If needed, capture the analytics service reference in `initState()` instead of `ref.read` in `dispose()`:

In `initState()` (add it if not present):

```dart
  late final WizardAnalyticsService _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = ref.read(wizardAnalyticsServiceProvider);
  }
```

And replace the `ref.read(wizardAnalyticsServiceProvider)` call in `dispose()` with `_analytics`. Re-run the test.

- [ ] **Step 6: Commit**

```bash
git add lib/features/schedule/presentation/wizard_page.dart \
        test/features/schedule/presentation/wizard_analytics_test.dart
git commit -m "feat(wizard): emit step_viewed/completed/back/abandoned events

Hooks PageView.onPageChanged + dispose() lifecycle. Production uses NoOp
(silent); test harness overrides with record=true. step_viewed fires once
for the first step via addPostFrameCallback. abandoned fires only when
_submit() did NOT run (i.e., user backed out before preview)."
```

---

### Task 8: Update n8n workflow system prompt for occupation branching

**Files:**
- Modify: `n8n/workflows/routinemon-weekly-schedule-wizard.json` (system prompt JS code at line ~29)

- [ ] **Step 1: Locate the prompt-building block**

Open `n8n/workflows/routinemon-weekly-schedule-wizard.json`. The system prompt is built in a Function node whose code starts at line ~29 with `const PROFANITY_KO = ...` and assigns to `sp` (system prompt) string. Find the section that emits `[USER PROFILE]` (search for `'\\n[USER PROFILE]\\n'`). The occupation block goes immediately after that section.

- [ ] **Step 2: Insert the occupation block**

After the `sp += 'Goal: ... + ', Fixed: ' + (answers.fixed_schedules || '-');` line (the last `[USER PROFILE]` line), insert this code block (keep existing lines unchanged; this is purely additive):

```js
// === [OCCUPATION CONTEXT] block (PR1) ===
const occProfile = answers.occupation_profile || null;
const askedFields = (occProfile && Array.isArray(occProfile.asked_fields))
  ? occProfile.asked_fields : [];
const isDefaulted = (field) => askedFields.length > 0 && !askedFields.includes(field);

sp += '\\n\\n[OCCUPATION CONTEXT]\\n';
sp += 'Status: ' + (answers.status || 'unknown') + '\\n';
if (occProfile) {
  if (occProfile.effective_status) sp += 'Effective status: ' + occProfile.effective_status + '\\n';
  if (occProfile.study_mode) sp += 'Study mode: ' + occProfile.study_mode + '\\n';
  if (occProfile.shift_pattern) sp += 'Shift pattern: ' + occProfile.shift_pattern + '\\n';
  if (askedFields.length > 0) sp += 'User-answered fields: ' + askedFields.join(', ') + '\\n';
}

switch (answers.status) {
  case 'homemaker':
    sp += 'INVARIANT (homemaker): generate housework slots daily. Do NOT generate work spine. ';
    sp += 'If work_days/work_hours are defaulted (not in user-answered fields), ignore them.\\n';
    break;
  case 'retired':
    sp += 'INVARIANT (retired): include morning walk daily, 3 meals at fixed times, social slots <= 2 per week. ';
    sp += 'If work_days/work_hours are defaulted, ignore them.\\n';
    break;
  case 'student':
    sp += 'INVARIANT (student): if study_mode=exam_period, prioritize study blocks 1.5x and reduce hobby slots. ';
    sp += 'If study_mode=vacation, increase self-development slots and reduce class spine.\\n';
    break;
  case 'worker':
    if (occProfile && occProfile.shift_pattern === 'night_shift') {
      sp += 'INVARIANT (worker, night_shift): include sleep recovery on weekend morning.\\n';
    }
    break;
  case 'freelancer':
    sp += 'INVARIANT (freelancer): work blocks should follow user focus_time, not 9-18.\\n';
    break;
}

if (mode === 'enhance') {
  sp += 'CRITICAL: preserve the occupation invariants above. Do not homogenize across statuses. ';
  sp += 'A homemaker schedule MUST differ structurally from a worker schedule.\\n';
}
// === end [OCCUPATION CONTEXT] block ===
```

This is JS embedded inside JSON, so newlines inside the assignment are literal `\\n` (two backslashes + n) in the JSON value, but the Function node parses them as `\n`. Match the existing escaping style of the file — if existing lines use `'\\n'` (double-escape) in the JSON source, use the same; if single-escape, match it.

- [ ] **Step 3: Validate JSON parses**

Run: `python -c "import json; json.load(open('n8n/workflows/routinemon-weekly-schedule-wizard.json', encoding='utf-8'))"`
Expected: Exits 0 (no parse errors). If JSONDecodeError, the escaping is wrong — fix the inserted block to match the file's existing escape conventions.

- [ ] **Step 4: Test the prompt locally (optional but recommended)**

If you have node installed and can run the workflow's Function node code in isolation: copy the entire JS body from the JSON `parameters.functionCode` (or equivalent), wrap in `function build($input) { ... return [{json:...}]; }`, feed a fake input matching `body.answers`, console.log the resulting `systemPrompt`. Confirm `[OCCUPATION CONTEXT]` appears with status-specific INVARIANT line.

If skipping, the manual smoke test in Task 11 is the safety net.

- [ ] **Step 5: Commit**

```bash
git add n8n/workflows/routinemon-weekly-schedule-wizard.json
git commit -m "feat(n8n): occupation-aware enhance prompt branching

Reads occupation_profile.effective_status + asked_fields. Emits
status-specific INVARIANT lines (homemaker housework, retired walk/meals/
social, student study_mode, worker night_shift, freelancer focus_time).
Enhance mode adds 'do not homogenize across statuses' constraint."
```

---

### Task 9: Document the 4 step-level events in analytics_events.md

**Files:**
- Modify: `docs/analytics_events.md`

- [ ] **Step 1: Locate the wizard events section**

Open `docs/analytics_events.md`. Find the `#### \`wizard_generated\`` heading (around line 235). The 4 new step-level events go immediately after that section (before the next `####` or `###` heading).

- [ ] **Step 2: Append the new event specs**

Insert this block after the existing wizard event definitions:

```markdown
#### `wizard_step_viewed`
- **trigger**: User views a wizard step (initial frame + every PageView page change).
- **properties**: `{ step_id: string (snake_case enum case name), step_index: int (0-based), total_steps: int, status: string|null (LifestyleStatus.name or null before status step) }`
- **kpi_mapping**: Per-step funnel; identifies which step users drop off at.
- **phase**: 5 (weekly-wizard-v2 PR1)
- **sdks**: [posthog, firebase_analytics]

#### `wizard_step_completed`
- **trigger**: User taps "다음" and advances to the next step.
- **properties**: `{ step_id: string, step_index: int, time_to_complete_ms: int (dwell time on the step) }`
- **kpi_mapping**: Per-step decision time; flags steps users hesitate on.
- **phase**: 5
- **sdks**: [posthog, firebase_analytics]

#### `wizard_step_back`
- **trigger**: User taps "이전" to return to a prior step.
- **properties**: `{ from_step_id: string, to_step_id: string }`
- **kpi_mapping**: Step regret rate; high values mean step labels are misleading.
- **phase**: 5
- **sdks**: [posthog, firebase_analytics]

#### `wizard_abandoned`
- **trigger**: WizardPage disposes without `_submit()` (preview not reached).
- **properties**: `{ last_step_id: string, step_index: int, total_steps: int }`
- **kpi_mapping**: Wizard funnel exit point distribution.
- **phase**: 5
- **sdks**: [posthog, firebase_analytics]
```

- [ ] **Step 3: Update the Last Updated date at the top**

Change line 5 (`> Last Updated: 2026-05-03`) to `> Last Updated: 2026-05-10`.

- [ ] **Step 4: Commit**

```bash
git add docs/analytics_events.md
git commit -m "docs(analytics): wizard_step_viewed/completed/back/abandoned spec

Defines properties + KPI mapping for the 4 step-level events emitted by
WizardAnalyticsService. NoOp impl ships in PR1; PostHog/Firebase wiring
lands in weekly-wizard-v2 Issue 08."
```

---

### Task 10: Full test sweep + analyze

**Files:**
- (no edits; verification only)

- [ ] **Step 1: Run flutter analyze repo-wide**

Run: `flutter analyze`
Expected: `No issues found!` (PRD DoD merge condition).

If any issue surfaces, fix it inline (likely an import or unused variable in the changed files). Re-run until clean.

- [ ] **Step 2: Run all schedule-feature tests**

Run: `flutter test test/features/schedule/`
Expected: All tests pass — new tests from Tasks 3, 5, 6, 7 + every pre-existing test in the directory.

If a pre-existing test breaks, the most likely cause is `WizardAnswers` no longer constructed with `occupationProfile` set in fixtures — but since the field is nullable with no default, the constructor signature is backward-compatible. If a test does break, it has a bug; fix it without changing production behavior.

- [ ] **Step 3: Run full test suite**

Run: `flutter test`
Expected: Whole repo green.

- [ ] **Step 4: Commit (if any fixes were needed)**

If Steps 1–3 required fixes, stage and commit:

```bash
git add -p   # stage only the fixes
git commit -m "test: keep existing tests green after PR1 OccupationProfile addition"
```

If no fixes were needed, skip this commit.

---

### Task 11: Manual smoke test on a real device

**Files:**
- (no edits; QA only)

- [ ] **Step 1: Boot the app**

Run: `flutter run` on the connected device or emulator.
Expected: App launches, wizard reachable from `/schedule/wizard`.

- [ ] **Step 2: Walk one full happy-path wizard for each occupation**

For each `LifestyleStatus` in `[worker, student, freelancer, homemaker, retired, other]`:
1. Open the wizard, pick that status.
2. Answer the remaining 14 steps with sensible defaults.
3. Reach the preview page.
4. Tap "AI 향상 실행" (LLM enhance).
5. Inspect the resulting items and confirm:
    - **homemaker:** schedule includes daily housework / family meal slots; no 9-18 work spine.
    - **retired:** morning walk slot + 3 fixed meal slots + ≤2 social slots/week.
    - **worker:** standard 9-18 work spine + commute buffer if commuteTime ≥ 1h.
    - **student:** study/learning blocks dominate.
    - **freelancer:** work blocks track the user's `focus_time`, not 9-18.
    - **other:** schedule is reasonable but generic.
6. If two statuses produce ≥70% identical schedules, the n8n prompt branching from Task 8 isn't taking effect. Re-check the JSON edit and the workflow's enhance-mode INVARIANT line.

- [ ] **Step 2 alternative if no LLM available:** Verify rule-based path A only

If `llama-server-8600-v2` is down or LLM enhance returns the seed unchanged, you can still verify PR1's data path:
- Check the device log for the `[wizard-analytics]` debugPrint lines firing on each step viewed/completed/back.
- In Network or n8n logs (if accessible), confirm the request body to `/webhook/routinemon/weekly-wizard` includes `occupation_profile.effective_status` and `asked_fields`.

If the payload is correct but enhance is unreachable, PR1 is still valid — the LLM differentiation is a runtime behavior gated on the LLM being up.

- [ ] **Step 3: Verify analytics events appear in debug log**

While walking the wizard, the debug log should show `[wizard-analytics] wizard_step_viewed: {...}`, `wizard_step_completed: {...}`, etc. This proves the NoOp service is wired correctly.

- [ ] **Step 4: No commit (this is QA only)**

If any issue surfaces, file it as a follow-up issue in `.scratch/weekly-wizard-v2/issues/` rather than amending PR1.

---

## NOT in scope for PR1 (deferred to PR2 or Issue 08)

- ✗ `OccupationFlow.stepsFor(status)` and the ≤7-step branched UI — PR2.
- ✗ `OccupationRuleSet` policy injection inside `RuleBasedPlanner` — PR2.
- ✗ Composite UI widgets (`_RhythmCompositeStep`, `_ExerciseCompositeStep`) — PR2.
- ✗ `kEnableOccupationFlow` feature flag — PR2 (no flag needed in PR1; everything is additive/silent).
- ✗ Real PostHog/Firebase wiring of analytics — Issue 08 (`.scratch/weekly-wizard-v2/issues/08-analytics-and-adr.md`).
- ✗ Per-occupation `askedFields` (homemaker excluding work_days/work_hours) — requires PR2's branched UI to know which fields each status asks.
- ✗ `study_mode` / `shift_pattern` user-facing inputs — PR2 wires them; PR1 only defines the schema.

---

## PR1 → PR2 trigger criteria

After PR1 ships, collect telemetry for ≥1 week. **Proceed to PR2 only if both conditions hold:**
1. `wizard_abandoned` concentrates ≥30% on a single step in the 6–10 range (commute / mealPattern / focusTime — generic-feeling questions for some statuses).
2. Manual smoke (Task 11 Step 2) shows ≥3 of the 6 statuses produce schedules that are ≥70% identical even after LLM enhance — i.e., n8n branching alone is insufficient.

If neither holds, PR2 is unjustified and the work stops here. Update `.scratch/weekly-wizard-v2/issues/` with the decision + telemetry snapshot.

---

## Self-review notes

- Spec coverage: every v3 plan PR1 item has at least one task. Task 1 (enums), Task 2 (OccupationProfile + WizardAnswers extension), Task 4 (state population), Task 6 (analytics interface), Task 7 (UI hooks), Task 8 (n8n branching), Task 9 (docs). Tests in Tasks 3, 5, 6, 7. Verification in Task 10. Smoke in Task 11.
- Placeholders: searched for "TBD", "implement later", "similar to" — none present. Each step has either a code block or an exact command.
- Type consistency: `OccupationProfile.effectiveStatus` (camelCase Dart) ↔ `effective_status` (snake_case JSON) used consistently across model, state population, snapshot test, n8n prompt. `askedFields` ↔ `asked_fields` consistent. `studyMode`/`shiftPattern` ↔ `study_mode`/`shift_pattern` consistent.
- A potential gap: the snapshot test in Task 5 uses a regex to map enum names to JsonValue strings; if any `LifestyleStatus` is later added with a `JsonValue` that doesn't match the camelCase-to-snake_case transform, the test silently fails on that status. The test docstring flags this; if it bites, replace with a hardcoded map.
