// Role-based wizard domain — UC2 절충 구현.
//
// 사용자 명시 2026-05-11: "각 첫 질문 (역할/직업) 기준 7-branch 분기. 마지막에
// LLM 을 통한 추가 질의나 명칭 변경 — LLM 이 필요할때만 호출."
//
// autoplan UC2 권고 (양 모델 critical): 7-role taxonomy 가 culturally brittle.
// 본 구현은 학생 1개 role 만 7-question 채움. 나머지 6개 role 은 enum + stub.
// 사용자 wake 후 결정에 따라 채우거나 role 수 축소.

import 'package:meta/meta.dart';

/// 위저드 첫 질문 — 사용자 주된 역할/직업.
enum Role {
  student,
  worker,
  freelancer,
  homemaker,
  selfEmployed,
  soldier,
  other;

  /// 한국어 디스플레이 라벨.
  String get displayLabel => switch (this) {
        Role.student => '학생',
        Role.worker => '직장인',
        Role.freelancer => '프리랜서',
        Role.homemaker => '주부',
        Role.selfEmployed => '자영업',
        Role.soldier => '군인',
        Role.other => '기타',
      };
}

/// 위저드 단일 선택지.
@immutable
class WizardOption {
  const WizardOption({required this.id, required this.label});
  final String id;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WizardOption && other.id == id && other.label == label);

  @override
  int get hashCode => Object.hash(id, label);
}

/// 위저드 단일 질문 (단일 선택형).
@immutable
class WizardQuestion {
  const WizardQuestion({
    required this.id,
    required this.label,
    required this.options,
  });
  final String id;
  final String label;
  final List<WizardOption> options;
}

/// 학생 role 의 7개 질문 — UC2 시드 구현.
const _studentQuestions = <WizardQuestion>[
  WizardQuestion(
    id: 'class_window',
    label: '평일 수업이 주로 언제 있나요?',
    options: [
      WizardOption(id: 'morning', label: '오전 (09-12시)'),
      WizardOption(id: 'afternoon', label: '오후 (13-17시)'),
      WizardOption(id: 'evening', label: '저녁 (18시 이후)'),
      WizardOption(id: 'mixed', label: '혼합'),
    ],
  ),
  WizardQuestion(
    id: 'exam_period',
    label: '현재 시험기간 인가요?',
    options: [
      WizardOption(id: 'yes', label: '예, 진행 중'),
      WizardOption(id: 'soon', label: '곧 (2주 내)'),
      WizardOption(id: 'no', label: '아니오'),
    ],
  ),
  WizardQuestion(
    id: 'commute',
    label: '통학 시간이 얼마나 걸리나요?',
    options: [
      WizardOption(id: 'live_in', label: '기숙사/자취 (0분)'),
      WizardOption(id: 'short', label: '30분 이내'),
      WizardOption(id: 'medium', label: '30분~1시간'),
      WizardOption(id: 'long', label: '1시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'part_time',
    label: '알바를 하고 있나요?',
    options: [
      WizardOption(id: 'none', label: '없음'),
      WizardOption(id: 'weekend', label: '주말만'),
      WizardOption(id: 'weeknight', label: '평일 저녁'),
      WizardOption(id: 'frequent', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'self_study',
    label: '하루 자율학습 목표 시간은?',
    options: [
      WizardOption(id: 'lt2', label: '2시간 미만'),
      WizardOption(id: 'two_four', label: '2-4시간'),
      WizardOption(id: 'four_six', label: '4-6시간'),
      WizardOption(id: 'gt6', label: '6시간 이상'),
    ],
  ),
  WizardQuestion(
    id: 'exercise',
    label: '운동/활동 주간 빈도는?',
    options: [
      WizardOption(id: 'none', label: '거의 안 함'),
      WizardOption(id: 'occasional', label: '주 1-2회'),
      WizardOption(id: 'regular', label: '주 3-5회'),
      WizardOption(id: 'daily', label: '거의 매일'),
    ],
  ),
  WizardQuestion(
    id: 'rest_preference',
    label: '쉬는 시간 선호는?',
    options: [
      WizardOption(id: 'short_frequent', label: '짧고 자주 (25/5분)'),
      WizardOption(id: 'long_block', label: '길게 한 번 (90분 집중 후 휴식)'),
      WizardOption(id: 'flexible', label: '유동적'),
    ],
  ),
];

/// 주어진 role 의 후속 질문 목록.
///
/// 학생만 채움. 다른 role 은 빈 리스트 (사용자 wake 후 결정).
List<WizardQuestion> questionsFor(Role role) {
  return switch (role) {
    Role.student => _studentQuestions,
    _ => const <WizardQuestion>[],
  };
}

/// 위저드 진행 중 답변 상태. Immutable.
///
/// 사용자가 role 을 바꾸면 [switchRole] 로 새 draft 를 만든다 — 이전 답변은
/// 폐기 (E1 fix: role-switch wipe).
@immutable
class RoleAnswerDraft {
  const RoleAnswerDraft({
    required this.role,
    this.answers = const <String, String>{},
  });

  final Role role;
  final Map<String, String> answers;

  RoleAnswerDraft setAnswer(String questionId, String optionId) {
    return RoleAnswerDraft(
      role: role,
      answers: {...answers, questionId: optionId},
    );
  }

  RoleAnswerDraft switchRole(Role newRole) {
    if (newRole == role) return this;
    return RoleAnswerDraft(role: newRole);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleAnswerDraft &&
          other.role == role &&
          _mapEquals(other.answers, answers));

  @override
  int get hashCode => Object.hash(role, Object.hashAllUnordered(answers.entries));

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}
