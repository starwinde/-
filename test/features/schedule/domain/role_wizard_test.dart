// Red: role-based wizard domain — Role enum + per-role question definition.
//
// 2026-05-12 Plan 2 scaffold. UC2 절충: 모든 role enum 정의 + 학생 1개 완전 구현.
// 다른 role 은 사용자 wake 후 결정에 따라 채움.

import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/schedule/domain/role_wizard.dart';

void main() {
  group('Role enum', () {
    test('defines 7 roles per user 명시 2026-05-11', () {
      expect(Role.values.length, 7);
    });

    test('학생 / 직장인 / 프리랜서 / 주부 / 자영업 / 군인 / 기타 in order', () {
      expect(Role.values.map((r) => r.name).toList(), [
        'student',
        'worker',
        'freelancer',
        'homemaker',
        'selfEmployed',
        'soldier',
        'other',
      ]);
    });

    test('Role.displayLabel returns Korean label', () {
      expect(Role.student.displayLabel, '학생');
      expect(Role.worker.displayLabel, '직장인');
      expect(Role.freelancer.displayLabel, '프리랜서');
      expect(Role.homemaker.displayLabel, '주부');
      expect(Role.selfEmployed.displayLabel, '자영업');
      expect(Role.soldier.displayLabel, '군인');
      expect(Role.other.displayLabel, '기타');
    });
  });

  group('Role.questionsFor — student (학생) full impl', () {
    test('returns 7 questions', () {
      final qs = questionsFor(Role.student);
      expect(qs.length, 7);
    });

    test('each question has stable id, label, and option list', () {
      final qs = questionsFor(Role.student);
      for (final q in qs) {
        expect(q.id, isNotEmpty);
        expect(q.label, isNotEmpty);
        expect(q.options, isNotEmpty);
        // Options are unique
        final ids = q.options.map((o) => o.id).toSet();
        expect(ids.length, q.options.length);
      }
    });

    test('first question is school_level (초/중/고/대 × 학원)', () {
      final qs = questionsFor(Role.student);
      expect(qs.first.id, 'school_level');
      expect(qs.first.options.length, 8);
      final ids = qs.first.options.map((o) => o.id).toList();
      expect(
        ids,
        containsAll(<String>[
          'elem_no',
          'elem_yes',
          'mid_no',
          'mid_yes',
          'high_no',
          'high_yes',
          'uni_no',
          'uni_yes',
        ]),
      );
    });

    test('class_window is now second question', () {
      final qs = questionsFor(Role.student);
      expect(qs[1].id, 'class_window');
    });
  });

  group('Role.questionsFor — all 6 non-student roles each have 7 questions', () {
    for (final role in [
      Role.worker,
      Role.freelancer,
      Role.homemaker,
      Role.selfEmployed,
      Role.soldier,
      Role.other,
    ]) {
      test('${role.name} has exactly 7 questions', () {
        expect(questionsFor(role).length, 7,
            reason: '${role.displayLabel} should ship 7 follow-up questions');
      });
      test('${role.name} questions have unique ids', () {
        final ids = questionsFor(role).map((q) => q.id).toSet();
        expect(ids.length, 7);
      });
      test('${role.name} questions each have non-empty option list', () {
        for (final q in questionsFor(role)) {
          expect(q.options, isNotEmpty);
          final optionIds = q.options.map((o) => o.id).toSet();
          expect(optionIds.length, q.options.length,
              reason: 'option ids must be unique within question ${q.id}');
        }
      });
    }
  });

  group('Role identity-shaping questions (per role first-question heuristic)', () {
    test('worker first question is work-form (근무 형태)', () {
      expect(questionsFor(Role.worker).first.id, 'work_form');
      expect(questionsFor(Role.worker).first.label, contains('근무'));
    });
    test('freelancer first question is focus-window (집중 가능 시간대)', () {
      expect(questionsFor(Role.freelancer).first.id, 'focus_window');
    });
    test('homemaker first question is care-load (돌봄 부담)', () {
      expect(questionsFor(Role.homemaker).first.id, 'care_load');
    });
    test('selfEmployed first question is business-hours (영업 시간대)', () {
      expect(questionsFor(Role.selfEmployed).first.id, 'business_hours');
    });
    test('soldier first question is service-type (복무 형태)', () {
      expect(questionsFor(Role.soldier).first.id, 'service_type');
    });
    test('other first question is daily-rhythm (생활 리듬)', () {
      expect(questionsFor(Role.other).first.id, 'daily_rhythm');
    });
  });

  group('RoleAnswer aggregation', () {
    test('builds empty answers for role', () {
      final aggregated = RoleAnswerDraft(role: Role.student);
      expect(aggregated.role, Role.student);
      expect(aggregated.answers, isEmpty);
    });

    test('answer setter is immutable (copy semantics)', () {
      const draft = RoleAnswerDraft(role: Role.student);
      final after = draft.setAnswer('class_window', 'morning');
      expect(draft.answers, isEmpty);
      expect(after.answers, {'class_window': 'morning'});
    });

    test('overwrites prior answer for same question id', () {
      const draft = RoleAnswerDraft(role: Role.student);
      final a = draft.setAnswer('class_window', 'morning');
      final b = a.setAnswer('class_window', 'afternoon');
      expect(b.answers, {'class_window': 'afternoon'});
    });

    test('changing role wipes prior answers (E1 fix)', () {
      const draft = RoleAnswerDraft(role: Role.student);
      final withAnswer = draft.setAnswer('class_window', 'morning');
      final switched = withAnswer.switchRole(Role.worker);
      expect(switched.role, Role.worker);
      expect(switched.answers, isEmpty);
    });
  });
}
