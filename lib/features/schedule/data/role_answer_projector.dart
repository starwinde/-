// RoleAnswerProjector — Eng A1 adapter.
//
// Bridges new role-based wizard (RoleAnswerDraft) onto legacy WizardAnswers
// shape so RuleBasedPlanner / WeeklyWizardService / n8n contract stays intact.
// Lossy by design: maps known keys, defaults the rest sensibly.

import 'package:routinemon/features/schedule/data/wizard_models.dart';
import 'package:routinemon/features/schedule/domain/lifestyle_enums.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';

class RoleAnswerProjector {
  RoleAnswerProjector._();

  static WizardAnswers project(RoleAnswerDraft draft) {
    final a = draft.answers;
    return WizardAnswers(
      status: _statusFor(draft.role),
      wakeTime: WakeTime.morning79,
      sleepTime: SleepTime.midnight231,
      chronotype: _chronotype(a),
      workDays: _workDays(draft.role, a),
      workHours: _workHours(draft.role, a),
      commuteTime: _commute(a),
      mealPattern: MealPattern.regular3,
      focusTime: _focusTime(draft.role, a),
      exercise: _exercise(a),
      exercisePreferredTime: null,
      hobby: _hobby(a),
      goalFocus: _goalFocus(draft.role, a),
      freeTime: _freeTime(a),
      fixedSchedules: null,
      userLocale: 'ko',
      pastWeekContext: null,
    );
  }

  static LifestyleStatus _statusFor(Role role) {
    return switch (role) {
      Role.student => LifestyleStatus.student,
      Role.worker => LifestyleStatus.worker,
      Role.freelancer => LifestyleStatus.freelancer,
      Role.homemaker => LifestyleStatus.homemaker,
      Role.selfEmployed => LifestyleStatus.other,
      Role.soldier => LifestyleStatus.other,
      Role.other => LifestyleStatus.other,
    };
  }

  static Chronotype _chronotype(Map<String, String> a) {
    final fw = a['focus_window'] ?? a['class_window'];
    return switch (fw) {
      'early_morning' || 'morning' => Chronotype.morning,
      'afternoon' || 'evening' => Chronotype.middle,
      'night' => Chronotype.evening,
      _ => Chronotype.middle,
    };
  }

  static WorkDays _workDays(Role role, Map<String, String> a) {
    final wf = a['work_form'];
    if (wf == 'flex') return WorkDays.remote;
    if (wf == 'shift') return WorkDays.irregular;
    if (role == Role.homemaker) return WorkDays.irregular;
    if (role == Role.freelancer) return WorkDays.remote;
    if (role == Role.soldier) {
      final dp = a['duty_pattern'];
      if (dp == 'shift' || dp == 'field') return WorkDays.irregular;
    }
    return WorkDays.d5;
  }

  static WorkHours _workHours(Role role, Map<String, String> a) {
    final wf = a['work_form'];
    return switch (wf) {
      'office_9_6' => WorkHours.nineToSix,
      'flex' => WorkHours.flexible,
      'shift' => WorkHours.nightOrShift,
      'field' => WorkHours.other,
      _ when role == Role.freelancer => WorkHours.flexible,
      _ when role == Role.homemaker => WorkHours.other,
      _ when role == Role.soldier => WorkHours.other,
      _ => WorkHours.flexible,
    };
  }

  static CommuteTime? _commute(Map<String, String> a) {
    final c = a['commute'] ?? a['commute_time'];
    return switch (c) {
      'live_in' || 'remote' || 'live-in' => CommuteTime.noCommute,
      'short' => CommuteTime.under30,
      'medium' => CommuteTime.about1h,
      'long' => CommuteTime.oneToTwoH,
      _ => null,
    };
  }

  static FocusTimeWindow _focusTime(Role role, Map<String, String> a) {
    final cw = a['class_window'] ?? a['focus_window'] ?? a['business_hours'];
    return switch (cw) {
      'early_morning' => FocusTimeWindow.earlyMorning,
      'morning' => FocusTimeWindow.morning,
      'afternoon' || 'standard' => FocusTimeWindow.afternoon,
      'evening' => FocusTimeWindow.evening,
      'night' || 'late_night' => FocusTimeWindow.night,
      _ => FocusTimeWindow.morning,
    };
  }

  static ExerciseFrequency _exercise(Map<String, String> a) {
    final e = a['exercise'] ?? a['pt_intensity'];
    return switch (e) {
      'none' => ExerciseFrequency.none,
      'occasional' => ExerciseFrequency.light,
      'regular' || 'standard' => ExerciseFrequency.moderate,
      'daily' || 'high' => ExerciseFrequency.daily,
      _ => ExerciseFrequency.light,
    };
  }

  static HobbyPreference _hobby(Map<String, String> a) {
    final h = a['hobby_preference'];
    return switch (h) {
      'rest' => HobbyPreference.none,
      'social' || 'hobby' => HobbyPreference.weekend,
      _ => HobbyPreference.weekend,
    };
  }

  static GoalFocus _goalFocus(Role role, Map<String, String> a) {
    final g = a['main_goal'] ?? a['goal'] ?? a['exam_period'];
    return switch (g) {
      'health' || 'fitness' => GoalFocus.health,
      'skill' || 'study' || 'yes' || 'soon' || 'transition' || 'promotion' =>
        GoalFocus.workStudy,
      'rest' || 'survive' => GoalFocus.rest,
      'reset' => GoalFocus.rest,
      _ => GoalFocus.workStudy,
    };
  }

  static FreeTimeMin _freeTime(Map<String, String> a) {
    // 학원=yes (school_level id 가 `_yes` 로 끝남) → 평일 저녁 슬롯 압축.
    final sl = a['school_level'];
    if (sl != null && sl.endsWith('_yes')) {
      return FreeTimeMin.oneHour;
    }
    final f = a['me_time'] ?? a['self_focus'];
    return switch (f) {
      'minimal' || 'short' => FreeTimeMin.oneHour,
      'medium' => FreeTimeMin.twoHours,
      'plenty' || 'long' || 'mostly' => FreeTimeMin.threeHoursPlus,
      _ => FreeTimeMin.twoHours,
    };
  }
}
