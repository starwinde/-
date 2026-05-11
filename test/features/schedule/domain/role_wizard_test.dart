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

    test('first question is class-schedule (수업 시간대)', () {
      final qs = questionsFor(Role.student);
      expect(qs.first.id, 'class_window');
      expect(qs.first.label, contains('수업'));
    });
  });

  group('Role.questionsFor — non-student roles (stub)', () {
    test('worker returns empty list (TODO — fill after user wake)', () {
      expect(questionsFor(Role.worker), isEmpty);
    });
    test('freelancer returns empty list (TODO)', () {
      expect(questionsFor(Role.freelancer), isEmpty);
    });
    test('homemaker returns empty list (TODO)', () {
      expect(questionsFor(Role.homemaker), isEmpty);
    });
    test('selfEmployed returns empty list (TODO)', () {
      expect(questionsFor(Role.selfEmployed), isEmpty);
    });
    test('soldier returns empty list (TODO)', () {
      expect(questionsFor(Role.soldier), isEmpty);
    });
    test('other returns empty list (TODO)', () {
      expect(questionsFor(Role.other), isEmpty);
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
