// Red: RoleAnswerProjector — bridges RoleAnswerDraft → legacy WizardAnswers.
//
// 2026-05-12 Eng A1 fix. Keeps RuleBasedPlanner / n8n contract unchanged.

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/data/role_answer_projector.dart';
import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/lifestyle_enums.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';

void main() {
  group('Role → LifestyleStatus mapping', () {
    test('student → student', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.student));
      expect(w.status, LifestyleStatus.student);
    });
    test('worker → worker', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.worker));
      expect(w.status, LifestyleStatus.worker);
    });
    test('freelancer → freelancer', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.freelancer));
      expect(w.status, LifestyleStatus.freelancer);
    });
    test('homemaker → homemaker', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.homemaker));
      expect(w.status, LifestyleStatus.homemaker);
    });
    test('selfEmployed → other (no closer enum)', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.selfEmployed));
      expect(w.status, LifestyleStatus.other);
    });
    test('soldier → other', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.soldier));
      expect(w.status, LifestyleStatus.other);
    });
    test('other → other', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.other));
      expect(w.status, LifestyleStatus.other);
    });
  });

  group('Defaults — empty answers produce valid WizardAnswers', () {
    test('all required fields have sensible defaults', () {
      final w = RoleAnswerProjector.project(
          const RoleAnswerDraft(role: Role.student));
      expect(w.wakeTime, WakeTime.morning79);
      expect(w.sleepTime, SleepTime.midnight231);
      expect(w.chronotype, Chronotype.middle);
      expect(w.workDays, WorkDays.d5);
      expect(w.workHours, WorkHours.flexible);
      expect(w.mealPattern, MealPattern.regular3);
      expect(w.focusTime, FocusTimeWindow.morning);
      expect(w.exercise, ExerciseFrequency.light);
      expect(w.hobby, HobbyPreference.weekend);
      expect(w.goalFocus, GoalFocus.workStudy);
      expect(w.freeTime, FreeTimeMin.twoHours);
      expect(w.userLocale, 'ko');
    });
  });

  group('Student answer mapping', () {
    test('class_window: morning → focusTime morning', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('class_window', 'afternoon');
      final w = RoleAnswerProjector.project(draft);
      expect(w.focusTime, FocusTimeWindow.afternoon);
    });
    test('commute: short → CommuteTime under30', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('commute', 'short');
      final w = RoleAnswerProjector.project(draft);
      expect(w.commuteTime, CommuteTime.under30);
    });
    test('commute: live_in → CommuteTime noCommute', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('commute', 'live_in');
      final w = RoleAnswerProjector.project(draft);
      expect(w.commuteTime, CommuteTime.noCommute);
    });
    test('exercise: daily → ExerciseFrequency daily', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('exercise', 'daily');
      final w = RoleAnswerProjector.project(draft);
      expect(w.exercise, ExerciseFrequency.daily);
    });
    test('exercise: none → ExerciseFrequency none', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('exercise', 'none');
      final w = RoleAnswerProjector.project(draft);
      expect(w.exercise, ExerciseFrequency.none);
    });
    test('exam_period: yes → goalFocus workStudy (시험기간)', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('exam_period', 'yes');
      final w = RoleAnswerProjector.project(draft);
      expect(w.goalFocus, GoalFocus.workStudy);
    });
    test('school_level: high_yes → freeTime oneHour (학원 다님)', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('school_level', 'high_yes');
      final w = RoleAnswerProjector.project(draft);
      expect(w.freeTime, FreeTimeMin.oneHour);
      expect(w.status, LifestyleStatus.student);
    });
    test('school_level: elem_no → freeTime default twoHours', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('school_level', 'elem_no');
      final w = RoleAnswerProjector.project(draft);
      expect(w.freeTime, FreeTimeMin.twoHours);
    });
    test('school_level: uni_yes → freeTime oneHour (대학생도 학원 다닐 수 있음)', () {
      final draft = const RoleAnswerDraft(role: Role.student)
          .setAnswer('school_level', 'uni_yes');
      final w = RoleAnswerProjector.project(draft);
      expect(w.freeTime, FreeTimeMin.oneHour);
    });
  });

  group('Worker answer mapping', () {
    test('work_form: shift → workHours nightOrShift', () {
      final draft = const RoleAnswerDraft(role: Role.worker)
          .setAnswer('work_form', 'shift');
      final w = RoleAnswerProjector.project(draft);
      expect(w.workHours, WorkHours.nightOrShift);
    });
    test('work_form: office_9_6 → workHours nineToSix', () {
      final draft = const RoleAnswerDraft(role: Role.worker)
          .setAnswer('work_form', 'office_9_6');
      final w = RoleAnswerProjector.project(draft);
      expect(w.workHours, WorkHours.nineToSix);
    });
    test('work_form: flex → workHours flexible + workDays remote', () {
      final draft = const RoleAnswerDraft(role: Role.worker)
          .setAnswer('work_form', 'flex');
      final w = RoleAnswerProjector.project(draft);
      expect(w.workHours, WorkHours.flexible);
      expect(w.workDays, WorkDays.remote);
    });
    test('commute_time: medium → CommuteTime about1h', () {
      final draft = const RoleAnswerDraft(role: Role.worker)
          .setAnswer('commute_time', 'medium');
      final w = RoleAnswerProjector.project(draft);
      expect(w.commuteTime, CommuteTime.about1h);
    });
  });

  group('Freelancer / Homemaker / Other answer mapping (smoke)', () {
    test('freelancer focus_window: night → focusTime night', () {
      final draft = const RoleAnswerDraft(role: Role.freelancer)
          .setAnswer('focus_window', 'night');
      expect(
        RoleAnswerProjector.project(draft).focusTime,
        FocusTimeWindow.night,
      );
    });
    test('homemaker me_time: minimal → freeTime oneHour', () {
      final draft = const RoleAnswerDraft(role: Role.homemaker)
          .setAnswer('me_time', 'minimal');
      expect(
        RoleAnswerProjector.project(draft).freeTime,
        FreeTimeMin.oneHour,
      );
    });
    test('other main_goal: health → goalFocus health', () {
      final draft = const RoleAnswerDraft(role: Role.other)
          .setAnswer('main_goal', 'health');
      expect(
        RoleAnswerProjector.project(draft).goalFocus,
        GoalFocus.health,
      );
    });
    test('other main_goal: rest → goalFocus rest', () {
      final draft = const RoleAnswerDraft(role: Role.other)
          .setAnswer('main_goal', 'rest');
      expect(
        RoleAnswerProjector.project(draft).goalFocus,
        GoalFocus.rest,
      );
    });
  });
}
